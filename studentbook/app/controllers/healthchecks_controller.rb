class HealthchecksController < ApplicationController

  def index
    if Healthcheck.healthy?
      render status: 200, json: "ok"
    else
      render status: 500, json: "failed"
    end
  end

end
