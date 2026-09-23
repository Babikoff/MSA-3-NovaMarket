# Реестры событий SAGA #

## Типы событий ##

- Domain s (доменные события)
- Failure s (события ошибок)
- Compensation s (компенсационные события)
- Timeout/Control s (события таймаутов)

## События при выборе товаров покупателем ##

*TODO*

## События при оформлении заказа ##

Реестр построен по выбранному паттерну **SAGA-хореография** (см. [ADR-02](ADR-02-SAGA-pattern-choice.md)); именование событий согласовано с [seq-order-placement-choreography-happy-path.puml](seq-order-placement-choreography-happy-path.puml), [seq-order-placement-choreography-payment-failed.puml](seq-order-placement-choreography-payment-failed.puml) и [seq-order-placement-choreography-delivery-scheduling-failed.puml](seq-order-placement-choreography-delivery-scheduling-failed.puml) и [seq-order-placement-choreography-buyer-cancel.puml](seq-order-placement-choreography-buyer-cancel.puml) и [seq-order-placement-choreography-stock-reservation-failed.puml](seq-order-placement-choreography-stock-reservation-failed.puml). 

| Этап                               | Тип события  | Название                                 | Издатель |
|:-----------------------------------|:------------:|-----------------------------------------:|:--------|
| Оформление заказа покупателем      |    domain    | CartConfirmed                            | Shopping Cart Service |
| Не удалось создать заказ           |   failure    | UnableToCreateOrder                      | Shopping Cart Service |
| Резервирование товаров успешно     |    domain    | StockReserved                            | Stock Service |
| Резервирование товаров не успешно  |   failure    | StockReservationFailed                   | Stock Service |
| Отмена резервирования товара       | compensation | StockReservationCancelled                | Stock Service |
| Инициирование оплаты заказа        |    domain    | OrderNeedsPayment                        | Order Service |
| Заказ явно отменён покупателем     | compensation | BuyerCancelledOrder                  | Order Service |
| Заказ отменён (компенсация сбоя)   | compensation | OrderCancelled                      | Order Service |
| Завершена отмена заказа            | compensation | OrderCancellationFinished            | Order Service |
| Списание средств успешно           |    domain    | PaymentSucceeded                         | Payment Service |
| Списание средств не успешно        |   failure    | PaymentFailed                            | Payment Service |
| Оплата отменена                    | compensation | PaymentCancelled                         | Payment Service |
| Сформирована заявка на доставку    |    domain    | DeliveryScheduled                        | Delivery Service |
| Заявка на доставку не сформирована | compensation | DeliverySchedulingFailed                 | Delivery Service |
| Заявка на доставку отменена        | compensation | DeliveryCancelled                        | Delivery Service |
| Уведомление продавцу о подготовке товара | domain | SellerNotifiedForDispatch            | (не в хореографии) |
| Уведомление покупателю об успешном оформлении | domain | BuyerNotifiedOrderConfirmed      | (не в хореографии) |
| Продавец окончательно подтвердил заказ | domain   | SellerConfirmedDeliveryOrder        | (не в хореографии) |
| Подтверждение заказа покупателем   |    domain    | OrderConfirmed                      | (не в хореографии) |
| Заказ не подтверждён покупателем   |   timeout    | OrderConfirmTimeout                 | (не в хореографии) |
| Не удалось осуществить доставку    | compensation | DeliveryFailed                      | (не в хореографии) |

## События при просмотре заказа покупателем ##

*TODO*

## События при просмотре заказа продавцом ##

*TODO*