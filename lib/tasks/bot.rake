namespace :bot do

  desc "Create Bot with name, printing out token to use in HTTP_BOT_AUTH"
  task :create, [:name] => :environment do |task, args|
    args.with_defaults name: 'ScribeBot'
    
    ret = BotUser.create args[:name]

    if ! ret[:token].blank?
      puts "Created #{ret[:user].name}. Use HTTP header to authenticate:"
      puts "  #{BotUser::AUTH_HEADER}=#{BotUser::pack_auth_header(ret[:user].id, ret[:token])}"
    else
      puts "#{ret[:user].name} already exists, so token can not be read but may be reset. Use bot:reset to reset token."
    end
  end

  desc "Reset Bot token with name, printing out token to use in HTTP_ROBOT_AUTH"
  task :reset, [:name] => :environment do |task, args|
    args.with_defaults name: 'ScribeBot'
    
    user = BotUser.find_by name: args[:name]
    token = user.reset_token!

    if token
      puts "Reset #{user.name}. Use HTTP header to authenticate:"
      puts "  #{BotUser::AUTH_HEADER}=#{BotUser::pack_auth_header(user.id, token)}"
    end
  end

  desc "Delete Bot by name"
  task :delete, [:name] => :environment do |task, args|
    if args[:name].blank?
      puts "No name given. Aborting."
      exit
    end
    
    user = BotUser.find_by name: args[:name]
    if user
      user.destroy
      puts "Removed #{user.name}"
    else
      puts "Bot user #{args[:name]} could not be found"
    end
  end

end
