desc "Imports data from a YAML in the lib/tasks/data directory"
task :import_data => :environment do
  ENV['BULK_UPDATE'] = '1'
  TABLEMAPPER = {
      'departments' => {
          :model => Department,
          :fields => {
              'name' => 'hotelname',
              'city' => 'deptcity',
              'short_name' => 'deptname',
              'state' => 'deptstate',
              'code' => 'deptcode'
          }
      },
      'users' => {
          :model => User,
          :fields => {
              'first_name' => 'firstname',
              'last_name' => 'lastname',
              'inactive' => 'enabled'
          }
      }
  }

  files = Dir.glob(File.join(Rails.root, 'lib', 'tasks', 'data','*.yml'))
  if files.size != 1
    puts "Found #{files.size} .yml files in the lib/tasks/data directory.  Must have only one file."
    return
  end

  f = File.open(files.first)
  line = ''

  until f.eof?
    line = f.gets until line.match(/^#/)
    k = line.chomp.gsub(/^# /, '')
    line = f.gets

    parseable = []
    until f.eof? or line.match(/^#/)
      parseable << line
      line = f.gets
    end

    puts parseable.size

    local_name = k.split(".")[1]
    if TABLEMAPPER[local_name]
      data = YAML.load(parseable.join(""))
#    puts data.inspect
      puts data.size

      klass = TABLEMAPPER[local_name][:model]
      case local_name
        when 'appquestions'
        else
          data.each do |entry|
            puts entry.inspect
            item = klass.find_or_create_by_id(entry['id'].to_i)
            klass.columns.each do |c|
              next if c.name == 'id'
              if c.sql_type == 'boolean'
                item.send("#{c.name}=", entry[TABLEMAPPER[local_name][:fields][c.name] || c.name] == 1)
              else
                item.send("#{c.name}=", entry[TABLEMAPPER[local_name][:fields][c.name] || c.name])
              end
            end
            if klass == User
              item.password = 'vaecorp'
              item.password_confirmation = 'vaecorp'
            end
            item.save
          end
      end
    else
      puts "Not processing #{local_name} as it is not mapped."
    end
  end

  User.all.each do |u|
    u.password = 'vaecorp'
    u.password_confirmation = 'vaecorp'
    u.inactive = !u.inactive
    u.save
  end
  ENV['BULK_UPDATE'] = '0'
  if (d = Department.first)
    d.update_remotes
  end
end