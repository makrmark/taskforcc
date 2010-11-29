class UserObserver < ActiveRecord::Observer
  def after_create(user)

    collaboration = Collaboration.new(
      :is_system => true,
      :subject => 'Personal',
      :description => 'Your private and personal taskforcc.',
      :created_by => user.id,
      :status => 'Open'
    )    
    collaboration.save!

  end
end