module UserUtility
  # Generates a nickname based on the user's email or name and ensures it is
  # unique by adding a number suffix to it in case the given nickname is
  # already taken.
  def generate_nickname(email, name)
    # Use the "name" as the primary source for the nickname and in case not
    # given or nil, use the email's first part.
    base_username = name.dup || email.split('@').first

    # Replace spaces and dots with underscore
    base_username.gsub!(/[\s\.]/, '_')

    # Make sure the name is unique
    username = base_username
    number = 1
    while Decidim::User.find_by(
      nickname: username,
      organization: current_organization,
    ).present?
      username = "#{base_username}_#{number}"
      number += 1
    end

    username
  end
end
