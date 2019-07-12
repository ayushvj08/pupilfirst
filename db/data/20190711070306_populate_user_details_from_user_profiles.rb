class PopulateUserDetailsFromUserProfiles < ActiveRecord::Migration[5.2]
  def up
    # Populate data for users in SV School
    sv_school = School.first

    sv_school.user_profiles.each do |user_profile|
      attributes = user_profile.slice(ATTRIBUTES)
      user = user_profile.user
      user.update!(
        school_id: sv_school.id,
        **attributes.symbolize_keys
      )

      next unless user_profile.avatar.attached?

      ActiveStorage::Attachment.where(
        name: 'avatar',
        record: user
      ).first_or_create!(
        blob: user_profile.avatar.blob
      )
    end

    # Create new users
    School.where.not(id: sv_school).each do |school|
      school.user_profiles.each do |user_profile|
        old_user = user_profile.user
        attributes = user_profile.slice(ATTRIBUTES)

        new_user = school.users.create!(
          email: old_user.email,
          **attributes.symbolize_keys
        )

        old_user.founders.joins(:school).where(schools: { id: school }).update_all(user: new_user)
        old_user.faculty.where(school: school).update_all(user: new_user)

        next unless user_profile.avatar.attached?

        ActiveStorage::Attachment.where(
          name: 'avatar',
          record: user
        ).first_or_create!(
          blob: user_profile.avatar.blob
        )
      end
    end

    # Add email for admin users
    AdminUser.all.each do |admin_user|
      admin_user.update!(email: admin_user.user.email)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
