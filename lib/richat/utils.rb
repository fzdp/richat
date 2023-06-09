module Richat
  class Utils
    class << self
      def deep_merge_hash(hs1, hs2)
        result = hs1.dup

        hs2.each do |key, value|
          if value.is_a?(Hash) && hs1[key].is_a?(Hash)
            result[key] = deep_merge_hash(result[key], value)
          else
            result[key] = value
          end
        end

        result
      end

      def absolute_path?(fp)
        File.expand_path(fp) == fp
      end

      def ensure_dir_exist(*dirs)
        dirs.each do |dir_name|
          if dir_name.nil? || dir_name.empty?
            puts "invalid directory"
            exit
          end
          FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
        end
      end
    end
  end
end