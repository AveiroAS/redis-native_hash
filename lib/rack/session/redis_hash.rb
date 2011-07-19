module Rack
  module Session
    class RedisHash < Abstract::ID

      def get_session(env, sid)
        session = Redis::NativeHash.find session_prefix => sid
        unless sid and session
          env['rack.errors'].puts("Session '#{sid.inspect}' not found, initializing...") if $VERBOSE and not sid.nil?
          session = Redis::NativeHash.new session_prefix
          sid = session.key
        end
        return [sid, session]
      end

      def set_session(env, session_id, session, options)
        unless session.kind_of?(Redis::NativeHash)
          real_session = Redis::NativeHash.new session_prefix
          real_session.update(session) if session.kind_of?(Hash)
          real_session.key = session_id unless session_id.nil?
          session = real_session
        end
        if options[:drop]
          session.destroy
          return false if options[:drop]
        end
        if options[:renew]
          session_id = session.renew_key
        end
        session.save
        return session_id
      end

      def session_prefix
        :rack_session
      end

    end
  end
end

