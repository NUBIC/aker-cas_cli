# A monkeypatch for Castanet issue #7.

require 'castanet/service_ticket'

module Castanet
  class ServiceTicket
    def retrieve_pgt!
      uri = URI.parse(proxy_retrieval_url).tap do |u|
        u.query = query(['pgtIou', pgt_iou])
      end

      net_http(uri).start do |h|
        u = uri.dup
        u.scheme = u.host = u.port = nil
        self.pgt = h.get(u.to_s).body
      end
    end
  end
end
