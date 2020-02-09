# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = User.create!(
  name: 'Admin',
  email: 'admin@email.com',
  password: 'password',
  admin: true
)

# PERSONALITIES = %w[ISTJ INFJ INTJ ENFJ ISTP ESFJ INFP ESFP ENFP ESTP ESTJ ENTJ
#                    INTP ISFJ ENTP ISFP].freeze

# PERSONALITIES.each do |personality|
#   Personality.create!(
#     trait: personality
#   )
# end

category = Category.create!(
  name: 'Programming'
)

for i in (1..100) do
  Project.create!(
    name: "Test Project #{i}",
    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam posuere, nulla lobortis pharetra ornare, eros metus vulputate orci, a cursus justo odio vitae nunc. In hac habitasse platea dictumst. Donec fermentum leo sed nisl consequat ultrices. In luctus, tellus a viverra tempor, turpis dui congue dui, quis ornare augue nunc vel metus. Proin non erat tempus, tristique urna sed, fringilla orci. Sed vitae nulla auctor, tempus ipsum nec, rhoncus augue. Pellentesque tortor diam, ullamcorper vitae elementum ut, laoreet nec erat. Fusce ac augue sagittis, scelerisque erat a, mattis mi. Fusce id odio convallis, porttitor enim in, hendrerit mi. Vivamus malesuada, metus vel condimentum interdum, eros libero dictum ante, id ultrices lacus ante sit amet magna. Maecenas facilisis laoreet urna, sit amet malesuada nisl pharetra non. Aenean in ornare urna. Pellentesque euismod arcu sed nibh hendrerit ornare. Cras cursus purus eget lacus condimentum condimentum. Vestibulum vitae erat sed leo porttitor ultricies.',
    status: 'Ongoing',
    visibility: 'Private',
    user: admin,
    category: category
  )
end