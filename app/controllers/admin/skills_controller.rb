# frozen_string_literal: true

class Admin::SkillsController < Admin::BaseController
  before_action :set_skill, only: %i[update destroy]

  def index
    @skills = Skill.with_category
    @categories = Category.select(:id, :name)
  end

  def create
    skill = Skill.new(skill_params)

    if skill.save
      render json: { skill: { id: skill.id, name: skill.name, category_name: skill.category.name } }
    else
      render json: { message: skill.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    return head :ok if @skill.update(skill_params)

    render json: { message: @skill.errors.full_messages }, status: :unprocessable_entity
  end

  def destroy
    @skill.destroy ? head(:ok) : head(:bad_request)
  end

  private

  def skill_params
    params.require(:skill).permit(:name, :category_id)
  end

  def set_skill
    @skill = Skill.find(params[:id])
  end
end
