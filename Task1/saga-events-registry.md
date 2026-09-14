# Реестры событий SAGA #

## Типы событий ##

- Domain Events (доменные события)
- Failure Events (события ошибок)
- Compensation Events (компенсационные события)
- Timeout/Control Events (события таймаутов)

## События при выборе товаров покупателем ##

*TODO*

## События при оформлении заказа ##

| Этап                               | Тип события  | Название                              |
|:-----------------------------------|:------------:|--------------------------------------:|
| Оформление заказа пользователем    |    domain    | OrderCreatedEvent             |
| Проверка наличия товаров           |    domain    | ProductsAvailabilityCheckSuccessEvent |
| Проверка наличия товара не успешна |   failure    | ProductsAvailabilityCheckFailedEvent  |
| Подтверждение заказа пользователем |    domain    | OrderConfirmedEvent                   |
| Заказ отменён пользователем        | compensation | BuyerCanceledOrderEvent               |
| Заказ не подтверждён пользователем |   timeout    | OrderConfirmTimeoutEvent              |
| Резервирование товаров успешно     |    domain    | ProductsReservationSuccessEvent       |
| Резервирование товаров не успешно  |   failure    | ProductsReserveFailedEvent            |
| Списание средств успешно           |    domain    | PaymentSuccessEvent                   |
| Списание средств не успешно        |   failure    | PaymentFailedEvent                    |
| Создана заявка на доставку         |    domain    | DeliveryOrderCreatedEvent             |
| Уведомление о заявке на доставку   |    domain    | DeliveryOrderCreatedNotification      |
| Продавец окончательно подтвердил заказ | domain   | SellerConfirmedDeliveryOrderEvent     |
| Заказ отменён пользователем        | compensation | SellerCanceledOrderEvent              |

## События при просмотре заказа покупателем ##

*TODO*

## События при просмотре заказа продавцом ##

*TODO*