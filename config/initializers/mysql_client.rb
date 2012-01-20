$rails_env = ENV['RAILS_ENV'] || 'development'
$db = case $rails_env
        when 'production' then 'kuponavt'
        when 'test' then 'kuponavt_test'
        when 'development' then 'kuponavt_development'
      end
MysqlClient = Mysql2::Client.new(:host => "localhost", :username => "root", :database => $db)
