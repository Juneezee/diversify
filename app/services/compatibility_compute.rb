# frozen_string_literal: true

class CompatibilityCompute < ComputeService
  def initialize(teams, unassigned)
    @teams = teams
    @unassigned = unassigned
  end

  def call(target)
    if @unassigned.id == target['team_id']
      best_team?(target, @teams)
    else
      team = @teams.where(id: target['team_id']).first
      puts(team.name)
      result = team_compatibility(target, team, team.users).round(2).to_s
      puts(result)
      result
    end
  end
end
