class ParserGenerator < Rails::Generators::NamedBase

  source_root File.expand_path('../templates', __FILE__)


  def copy_parser_file
    create_file "app/parsers/#{file_name}.rb", <<-FILE
class #{class_name} < Parser::Base
end
    FILE
  end

end
