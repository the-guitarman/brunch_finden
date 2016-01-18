unless defined?(Fleximage)
  puts "== Warning: Fleximage is not defined."
  
else
  require 'fleximage/blank' unless defined?(Fleximage::Blank)

  ################### Fleximage extensions ###################################
  #generic method to determine the fileserver id_path from a given id
  module Fileserver
    def self.get_id_directory(id)
      if id
        id_s=id.to_s
        id_path=
          if id_s.size>3
            id_s[0..-4]
          else
            "0"
          end
        ret = id_path
      else
        ret = 'no_id_given'
      end
      return ret
    end

    def self.get_id_path(id)
      "/#{Fileserver.get_id_directory(id)}"
    end
  end


  #Fix on Fleximage to use our directory convention.
  # storage_dir/id_path/
  # id_path is the image id without the last three digits
  # ex.: 12345 => 12
  module Fleximage
    module Model
      module InstanceMethods
        def url_directory
          Fileserver.get_id_directory(self[:id])
        end

        def url_directory_path
          Fileserver.get_id_path(self[:id])
        end

        def directory_path
          # base directory
          directory = "#{Rails.root}/#{self.class.image_directory}"
          "#{directory}/#{url_directory}"
        end
        
        def image_file_url=(file_url)
          @image_file_url = file_url
          if file_url =~ %r{^(https?|ftp)://}
            file = open(file_url)

            # Force a URL based file to have an original_filename
            eval <<-CODE
              def file.original_filename
                "#{file_url}"
              end
            CODE

            self.image_file = file
          
          # NEW ++++++++++++++++++++++++
          elsif file_url =~ %r{^file://}
            self.image_file = File.open(file_url.gsub(%r{^file://},''), 'r')
          # NEW ------------------------

          elsif file_url.empty?
            # Nothing to process, move along

          else
            # invalid URL, raise invalid image validation error
            @invalid_image = true
          end
        end

  #      # User-Agent added to download more images.
  #      # This test seems to work, but the implementation may be unlucky.
  #      alias_method :original_image_file_url, :image_file_url
  #      def image_file_url=(file_url)
  #        @image_file_url = file_url
  #        if file_url =~ %r{^(https?|ftp)://}
  #          file = open(file_url,
  #            'User-Agent' => 'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.0.11) Gecko/2009060309 Ubuntu/9.04 (jaunty) Firefox/3.0.11 FirePHP/0.3',
  #            #"From" => "foo@bar.invalid",
  #            "Referer" => "http://www.yopi.co.uk/"
  #          )
  #
  #          # Force a URL based file to have an original_filename
  #          eval <<-CODE
  #            def file.original_filename
  #              "#{file_url}"
  #            end
  #          CODE
  #
  #          self.image_file = file
  #
  #        elsif file_url.empty?
  #          # Nothing to process, move along
  #
  #        else
  #          # invalid URL, raise invalid image validation error
  #          @invalid_image = true
  #        end
  #      end

        def validate_size_in_scope_of_image_type
          if self.class.require_image
            field_name = (@image_file_url && @image_file_url.present?) ? :image_file_url : :image_file
            if !@uploaded_image.nil?
              x,y = self.image_size_to_validate

              if @uploaded_image.columns < x || @uploaded_image.rows < y
                minimum_size = "#{x}x#{y}"
                fallback = "is too small (Minimum: %{minimum})"
                translation = self.class.translate_error_message("image_too_small", 
                  fallback.gsub("%{minimum}", minimum_size), :minimum => minimum_size
                )
                errors.add field_name, translation
              end
            end
          end
        end

        def image_size_to_validate
          raise NoMethodError, "You defined 'validate :validate_size_in_scope_of_image_type' in your model. " +
             "You need to define 'image_size_to_validate' as public instance method in addition. " +
            "It should return an array which includes the current image size to validate ([x,y])."
        end
      end
    end
  end

end