# typed: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  extend T::Sig
end
