module PostGISAdapter
  class Railtie < Rails::Railtie

    rake_tasks do
      require 'active_record/tasks/postgis_database_tasks'
      ActiveRecord::Tasks::DatabaseTasks.register_task(/postgis/, ActiveRecord::Tasks::PostGISDatabaseTasks)
    end

  end
end
