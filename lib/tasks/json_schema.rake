require 'json'
require 'open-uri'

namespace :json_schema do
  desc "TODO"
  task mig_template_datum: :environment do
    TemplateDatum.find_each do |td|
      url = td.files[:schema]
      puts "url=#{url}"
      begin
        # schema = JSON.parse(File.read("./card_schemas/to_record_land_conflict_schema.json"));
        schema = JSON.parse(open(url).read)
        fields = schema["properties"]["data"]["properties"]

        if schema["properties"]["data"].key?("required")
          fields_req = schema["properties"]["data"]["required"]
        end

        fields.each do |key, val|
          @template_field = TemplateField.new
          @template_field.template_datum_id = td.id
          field_name = key
          @template_field.name = field_name

          if val.key?("title")
            field_title = val["title"]
            @template_field.title = field_title
          end

          if val.key?("type")
            field_type = val["type"]
            @template_field.data_type = field_type
            if fields_req
              field_req = fields_req.include?(key)
              @template_field.is_req = field_req
            end
            if val.key?("default")
              field_def = val["default"]
              @template_field.default = field_def
            end
            if val.key?("enum")
              field_enum = val["enum"]
              @template_field.enum = field_enum
            end
            if val.key?("enumNames")
              field_enum_names = val["enumNames"]
              @template_field.enum_names = field_enum_names
            end

            # print "#{field_name}|#{field_title}|#{field_type}|#{field_req}|#{field_def}|#{field_enum}|#{field_enum_names}"
            if field_type == "boolean"
              # puts ""
            elsif field_type == "number"
              if val.key?("minimum")
                field_min = val["minimum"]
                @template_field.min = field_min
              end
              if val.key?("maximum")
                field_max = val["maximum"]
                @template_field.max = field_max
              end
              if val.key?("multipleOf")
                field_mul_of = val["multipleOf"]
                @template_field.multiple_of = field_mul_of
              end
              if val.key?("exclusiveMinimum")
                field_ex_min = val["exclusiveMinimum"]
                @template_field.ex_min = field_ex_min
              end
              if val.key?("exclusiveMaximum")
                field_ex_max = val["exclusiveMaximum"]
                @template_field.ex_max = field_ex_max
              end
              # puts "#{field_min}|#{field_max}|#{field_mul_of}|#{field_ex_min}|#{field_ex_max}"
              # @template_field.assign_attributes(min: field_min, max: field_max, multiple_of: field_mul_of, ex_min: field_ex_min, ex_max: field_ex_max)
            elsif field_type == "string"
              if val.key?("minLength")
                field_min_len = val["minLength"]
                @template_field.min_length = field_min_len
              end
              if val.key?("maxLength")
                field_max_len = val["maxLength"]
                @template_field.max_length = field_max_len
              end
              if val.key?("format")
                field_format = val["format"]
                  @template_field.format = field_format
              end
              if val.key?("pattern")
                field_pattern = val["pattern"]
                  @template_field.pattern = field_pattern
              end
              # puts "#{field_min_len}|#{field_max_len}|#{field_format}|#{field_pattern}"
              # @template_field.assign_attributes(format: field_format, pattern: field_pattern, min_length: field_min_len, max_length: field_max_len)
            elsif field_type == "array"
              # puts ""
            end
            if @template_field.save
              puts "Saved #{@template_field.id}, #{@template_field.name}"
            else
              puts "Cannot Save #{@template_field.id}, #{@template_field.name}"
            end
          end
        end
      rescue OpenURI::HTTPError
        puts "No schema at #{url}"
      end
    end
  end
end
