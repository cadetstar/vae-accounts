class Department < ActiveRecord::Base
  belongs_to :supervising_department, :class_name => 'Department'
  belongs_to :manager, :class_name => 'User'
  belongs_to :supervisor, :class_name => 'User'

  before_save :set_supervisor
  after_save :update_remotes

  def update_remotes
    require 'net/http'
    require 'uri'

    $remotes_to_update.each do |host|
      uri = URI.parse(host + 'start_query')
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
    end
  end

  def self.list_for_select(exclusion = nil)
    Department.where("COALESCE(name, '') != ''").collect{|d| [d, d.id]}
  end

  def set_supervisor
    if self.supervising_department
      self.supervisor = self.supervising_department.manager
    else
      self.supervisor = nil
    end
  end

  def destroy
    t = "Department #{self.id}/#{self.code} destroyed."
    super
    t
  end

  def city_and_state
    [city, state].compact.join(", ")
  end

  def to_s
    if city_and_state.blank?
      name
    else
      "#{name}, #{city_and_state}"
    end
  end
end
