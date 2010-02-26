class IwiwUser < ActiveRecord::Base

  def to_param
    self.screen_name
  end
end
