# frozen_string_literal: true

require_relative '../appsec/instrumentation/gateway/argument'

module Datadog
  module Kit
    # Tracking identity via traces
    module Identity
      # Attach user information to the trace
      #
      # @param trace [TraceOperation] Trace to attach data to. Defaults to
      #   active trace.
      # @param span [SpanOperation] Span to attach data to. Defaults to
      #   active span on trace. Note that this should be a service entry span.
      #   When AppSec is enabled, the expected span and trace are automatically
      #   used as defaults.
      # @param id [String] Mandatory. Username or client id extracted
      #   from the access token or Authorization header in the inbound request
      #   from outside the system.
      # @param email [String] Email of the authenticated user associated
      #   to the trace.
      # @param name [String] User-friendly name. To be displayed in the
      #   UI if set.
      # @param session_id [String] Session ID of the authenticated user.
      # @param role [String] Actual/assumed role the client is making
      #   the request under extracted from token or application security
      #   context.
      # @param scope [String] Scopes or granted authorities the client
      #   currently possesses extracted from token or application security
      #   context. The value would come from the scope associated with an OAuth
      #   2.0 Access Token or an attribute value in a SAML 2.0 Assertion.
      # @param others [Hash<Symbol, String>] Additional free-form
      #   user information to attach to the trace.
      #
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/AbcSize
      def self.set_user(trace = nil, span = nil, id:, email: nil, name: nil, session_id: nil, role: nil, scope: nil, **others)
        raise ArgumentError, 'missing required key: :id' if id.nil?

        # enforce types

        raise TypeError, ':id must be a String'         unless id.is_a?(String)
        raise TypeError, ':email must be a String'      unless email.nil? || email.is_a?(String)
        raise TypeError, ':name must be a String'       unless name.nil? || name.is_a?(String)
        raise TypeError, ':session_id must be a String' unless session_id.nil? || session_id.is_a?(String)
        raise TypeError, ':role must be a String'       unless role.nil? || role.is_a?(String)
        raise TypeError, ':scope must be a String'      unless scope.nil? || scope.is_a?(String)

        others.each do |k, v|
          raise TypeError, "#{k.inspect} must be a String" unless v.nil? || v.is_a?(String)
        end

        if (appsec_scope = Datadog::AppSec.active_scope)
          trace = appsec_scope.trace
          span = appsec_scope.span
        end

        trace ||= Datadog::Tracing.active_trace
        span ||= trace.active_span || Datadog::Tracing.active_span

        if trace.trace_id != span.trace_id
          raise ArgumentError, "span #{span.span_id} does not belong to trace #{trace.trace_id}"
        end

        # set tags once data is known consistent

        span.set_tag('usr.id', id)
        span.set_tag('usr.email', email)           unless email.nil?
        span.set_tag('usr.name', name)             unless name.nil?
        span.set_tag('usr.session_id', session_id) unless session_id.nil?
        span.set_tag('usr.role', role)             unless role.nil?
        span.set_tag('usr.scope', scope)           unless scope.nil?

        others.each do |k, v|
          span.set_tag("usr.#{k}", v) unless v.nil?
        end

        if appsec_scope
          user = ::Datadog::AppSec::Instrumentation::Gateway::User.new(id)
          ::Datadog::AppSec::Instrumentation.gateway.push('identity.set_user', user)
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
