# -*- coding: utf-8 -*-
require 'yaml'

module Ishiki
  
  def level(text)
    words = YAML.load_file('./data/words.yml')
    level = 0
    words.each do | w |
      if text.match(/#{w['name']}/)
        level += w['value']
      end
    end
    level
  end

  def high_level?(text)
    level(text) >= 5
  end
  
  module_function :level, :high_level?

end
