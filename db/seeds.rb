require "factory_girl"
#FactoryGirl.find_definitions

FactoryGirl.create_list(:instrument, 30)
FactoryGirl.create_list(:jam_group, 200)
instrument_ids = Instrument.all.map(&:id)
jam_group_ids = JamGroup.all.map(&:id)

proficiencies = [:Newb, :Beginner, :Novice, :Intermediate, :Experienced, :Expert, :Virtuoso]
statuses = [0, 1]
password = User.new(:password => "password").encrypted_password

users = []
profiles = []
instrument_profiles = []
members = []
comments = []


1000.times do |n|
  users << "(#{n}, 'person#{n}@example.com', '#{password}', NOW(), NOW())"
  profiles << "(#{n}, NOW(), NOW(), #{n}, 'First#{n}', 'Last#{n}', #{(1..120).to_a.sample}, 'Santa Barbara, CA', 'Bio #{n}')" 
  instrument_ids.sample((1..5).to_a.sample).each do |i|
    instrument_profiles << "(#{n}, #{i}, '#{proficiencies.sample}', '#{[true, false].sample}', NOW(), NOW())" 
  end
  jam_group_ids.sample((2..10).to_a.sample).each do |j|
    members << "(#{n}, #{j}, #{n}, '#{statuses.sample}', NOW(), NOW())"

    ((10..50).to_a.sample).times do |k|
      comments << "(#{j}, #{n}, 'Comment #{k} from user #{n}', NOW(), NOW())"
    end
  end
end

User.transaction do
  User.connection.execute "INSERT INTO users (id, email, encrypted_password, created_at, updated_at) VALUES #{users.join(', ')}"
end

Profile.transaction do
  Profile.connection.execute "INSERT INTO profiles (id, created_at, updated_at, user_id, first_name, last_name, age, location, bio) VALUES #{profiles.join(', ')}"
end

InstrumentProfile.transaction do
  Instrument.connection.execute "INSERT INTO instrument_profiles (profile_id, instrument_id, proficiency, owned, created_at, updated_at) VALUES #{instrument_profiles.join(', ')}"
end

JamGroupMember.transaction do
  JamGroupMember.connection.execute "INSERT INTO jam_group_members (profile_id, jam_group_id, invited_by, status, created_at, updated_at) VALUES #{members.join(', ')}"
end

Comment.transaction do
  Comment.connection.execute "INSERT INTO comments (jam_group_id, profile_id, comment, created_at, updated_at) VALUES #{comments.join(', ')}"
end

