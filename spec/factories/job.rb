# ~*~ encoding: utf-8 ~*~
require 'factory_girl'
require 'faker'

FactoryGirl.define do

  factory :job, class: JudgeJob do

    name        { Faker::Company.name }
    to_create   {}

    trait :basic do
      ignore do
        basic   { Test::ROOT + 'data' + 'basic_job' }
      end
      output  { (basic + 'output').to_s }
      inputs  { Dir[basic + 'inputs' + '*.yml'].map { |i| Input.new local: i } }
    end

  end

end
