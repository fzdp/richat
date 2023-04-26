module Richat
  class ColorCode
    COLOR_CODE = {
      black: "\e[30m",
      red: "\e[31m",
      green: "\e[32m",
      yellow: "\e[33m",
      blue: "\e[34m",
      magenta: "\e[35m",
      cyan: "\e[36m",
      white: "\e[37m"
    }

    class << self
      def get_code(color)
        COLOR_CODE.fetch(color.to_sym, nil)
      end
    end
  end
end