# frozen_string_literal: true

require 'rails_helper'

describe CategoriesController, type: :request do
  describe 'GET #index' do
    subject(:request) { get categories_path }

    it_behaves_like 'returns 404 Not Found'
  end

  describe 'GET #index XHR' do
    subject(:request) do
      get categories_path, xhr: true, headers: { accept: 'application/json' }
    end

    it_behaves_like 'returns JSON response'
  end
end
