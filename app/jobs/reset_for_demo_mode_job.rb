# frozen_string_literal: true

class ResetForDemoModeJob < ApplicationJob
  include DemomodeHelper

  queue_as :schedule

  def perform
    unless demo_mode?
      logger.warn("Zealot is not in demo mode, can not execute ResetForDemoModeJob.")
      return
    end

    clean_app_data
    init_demo_data
    reset_jobs
  end

  private

  def clean_app_data
    # Application
    App.delete_all
    DebugFile.delete_all
    Metadatum.delete_all

    # Admin
    User.delete_all
    Setting.delete_all
    AppleKey.delete_all
  end

  def reset_jobs
    GoodJob::Job.all.each do |job|
      job.destroy_job
    end
  end

  def init_demo_data
    user = CreateAdminService.new.call
    CreateSampleAppsService.new.call(user)
  end
end
