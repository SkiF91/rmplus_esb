namespace :redmine do
  namespace :rmplus_esb do
    task set_deleted_to_employees_1c: :environment do
      ResbEmployee1c.transaction do
        users = ResbEmployee1c.preload(:user).where(deleted: false).where('fire_date is not null and fire_date < ?', Date.today)
        users.each do |user|
          puts "#{user.name}"
        end
        ResbEmployee1c.where(deleted: false).where('fire_date is not null and fire_date < ?', Date.today).update_all(deleted: true)
      end
    end

    task unset_deleted_to_employees_1c: :environment do
      ResbEmployee1c.where(deleted: true).where('fire_date is not null and fire_date < ?', Date.today).update_all(deleted: false)
    end
  end
end