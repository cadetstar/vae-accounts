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
  lines = f.readlines

  parseables = {}
  data = {}

  lines.shift until lines[0].match(/^#/)

  until lines.empty?
    k = lines[0].chomp.gsub(/^# /, '')
    lines.shift
    parseables[k] = []
    until lines.empty? or lines[0].match(/^#/)
      parseables[k] << lines.shift
    end
    data[k] = YAML.load(parseables[k].join(""))
  end
  puts data.inspect
  #puts parseables.inspect
  data.keys.each do |k|
    local_name = k.split(".")[1]
    if TABLEMAPPER[local_name]
      klass = TABLEMAPPER[local_name][:model]
      case local_name
        when 'appquestions'
        else
          data[k].each do |line|
            puts "Trying to load: #{line}"
            item = klass.find_or_create_by_id(line['id'])
            klass.columns.each do |c|
              next if c.name == 'id'
              if c.name == 'encrypted_password'
                item.send("password=", 'vaecorp')
              else
                if c.sql_type == 'boolean'
                  item.send("#{c.name}=", line[TABLEMAPPER[local_name][:fields][c.name] || c.name] == 1)
                else
                  item.send("#{c.name}=", line[TABLEMAPPER[local_name][:fields][c.name] || c.name])
                end
              end
            end
            item.save
          end
      end
    end
  end
  User.all.each do |u|
    u.password = 'vaecorp'
    u.password_confirmation = 'vaecorp'
    u.inactive = !u.inactive
    u.save
  end
  ENV['BULK_UPDATE'] = '0'
  Department.first.update_remotes
end