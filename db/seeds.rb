# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

uploader_group = Group.create(name: 'log_uploader')
User.create(email: 'test@test.com', password: 'Password123', password_confirmation: 'Password123', group: uploader_group)
