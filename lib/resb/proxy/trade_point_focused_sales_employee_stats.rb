class Resb::Proxy::TradePointFocusedSalesEmployeeStats < Resb::Proxy::Core::Body
  node_accessor login: { name: 'employeeDomainLogin' },
                percent: { name: 'salesPercentage' }
end