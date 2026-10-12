module Api
  module V1
    class AnalyticsController < ApplicationController
      def summary
        render json: analytics_service.summary
      end

      def by_department
        render json: analytics_service.by_department
      end

      def by_country
        render json: analytics_service.by_country
      end

      def by_designation
        render json: analytics_service.by_designation
      end

      private

      def analytics_service
        @analytics_service ||= SalaryAnalyticsService.new
      end
    end
  end
end
