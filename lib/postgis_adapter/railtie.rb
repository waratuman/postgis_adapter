require 'active_record/tasks/postgis_database_tasks'

module PostGISAdapter
  class Railtie < Rails::Railtie

    initializer 'postgis_adapter' do
      ActiveRecord::Tasks::DatabaseTasks.register_task(/postgis/, ActiveRecord::Tasks::PostGISDatabaseTasks)
    end

  end
end
