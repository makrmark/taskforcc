class Act < ActiveRecord::Base
  belongs_to :activity

  def new_value
    case self.attribute_type
    when 'string', 'integer-string'
      self.string_val
    when 'integer'
      self.integer_val
    when 'datetime'
      self.datetime_val
    end
  end
  
  def old_value
    case self.attribute_type
    when 'string', 'integer-string'
      self.string_val_was
    when 'integer'
      self.integer_val_was
    when 'datetime'
      self.datetime_val_was
    end
  end
end
