post 'esb/package', controller: :esb, action: :package

resources :resb_trade_points, only: [:index, :edit, :update]

get 'esb/request_staffing_comment_file/(:guid)', controller: 'esb', action: 'request_staffing_comment_file'