require_relative '../../src/singler'

class SinglerStub

  def self.define_stubs(*names)
    names.each do |name|
      if Singler.new(nil).respond_to?(name)
        define_method name do |*_args|
          "hello from SinglerStub.#{name}"
        end
      end
    end
  end

  define_stubs :sha
  define_stubs :create, :manifest
  define_stubs :id?, :id_completed, :id_completions
  define_stubs :ran_tests, :increments
  define_stubs :visible_file, :visible_files
  define_stubs :tag_visible_files, :tags_visible_files

end
