# Реестры событий SAGA #

## Типы событий ##

- Domain s (доменные события)
- Failure s (события ошибок)
- Compensation s (компенсационные события)
- Timeout/Control s (события таймаутов)

## События при выборе товаров покупателем ##

*TODO*

## События при оформлении заказа ##

Реестр построен по выбранному паттерну **SAGA-хореография** (см. [ADR-02](ADR-02-SAGA-pattern-choice.md)); именование событий согласовано с [seq-order-placement-choreography-happy-path.puml](seq-order-placement-choreography-happy-path.puml), [seq-order-placement-choreography-payment-failed.puml](seq-order-placement-choreography-payment-failed.puml) и [seq-order-placement-choreography-delivery-scheduling-failed.puml](seq-order-placement-choreography-delivery-scheduling-failed.puml) и [seq-order-placement-choreography-buyer-cancel.puml](seq-order-placement-choreography-buyer-cancel.puml). 

| Этап                               | Тип события  | Название                                 |
|:-----------------------------------|:------------:|-----------------------------------------:|
| Оформление заказа покупателем      |    domain    | CartConfirmed                            |
| Инициирование оплаты заказа        |    domain    | PaymentInitiated                         |
| Резервирование товаров успешно     |    domain    | StockReserved                            |
| Резервирование товаров не успешно  |   failure    | StockReservationFailed                   |
| Снятие резервирования товара       | compensation | StockReservationCancelled                |
| Списание средств успешно           |    domain    | PaymentSucceeded                         |
| Списание средств не успешно        |   failure    | PaymentFailed                            |
| Оплата отменена        | compensation | PaymentCancelled                            |
| Сформирована заявка на доставку    |    domain    | DeliveryScheduled                        |
| Заявка на доставку не сформирована | compensation | DeliverySchedulingFailed                 |
| Заявка на доставку отменена        | compensation | DeliveryCancelled                        |
| Уведомление продавцу о подготовке товара | domain | SellerNotifiedForDispatch                |
| Уведомление покупателю об успешном оформлении | domain | BuyerNotifiedOrderConfirmed         |
| Уведомление покупателю об отмене заказа | domain | BuyerNotifiedOrderCancelled          |
| Продавец окончательно подтвердил заказ | domain   | SellerConfirmedDeliveryOrder        |
| Подтверждение заказа покупателем   |    domain    | OrderConfirmed                      |
| Заказ отменён покупателем          | compensation | BuyerCancelledOrder                  |
| Заказ отменён автоматически | compensation | OrderAutomaticallyCancelled |
| Заказ не подтверждён покупателем   |   timeout    | OrderConfirmTimeout                 |
| Не удалось осуществить доставку    | compensation | DeliveryFailed                 |

## События при просмотре заказа покупателем ##

*TODO*

## События при просмотре заказа продавцом ##

*TODO*