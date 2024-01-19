services=('admin' 'apigateway' 'auth' 'delivery' 'notification' 'order' 'payment' 'product' 'store' 'user' 'wishlist' 'orderquery' 'giftcard')


for ((i=0; i<${#services[@]}; i++)); do
  service=${services[i]}
  sh $service-blue-green.sh
done
