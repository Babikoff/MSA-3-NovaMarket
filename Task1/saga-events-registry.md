# Реестры событий SAGA #

## Типы событий ##

- Domain s (доменные события)
- Failure s (события ошибок)
- Compensation s (компенсационные события)
- Timeout/Control s (события таймаутов)

## События при выборе товаров покупателем ##

*TODO*

## События при оформлении заказа ##

Реестр построен по выбранному паттерну **SAGA-хореография** (см. [ADR-02](ADR-02-SAGA-pattern-choice.md)); именование событий согласовано с [seq-order-placement-detailed-choreography.puml](seq-order-placement-detailed-choreography.puml). Диаграммы показывают happy path, поэтому события ошибок и компенсации моделируются отдельно и включаются в реестр дополнительно.

| Этап                               | Тип события  | Название                                 |
|:-----------------------------------|:------------:|-----------------------------------------:|
| Оформление заказа покупателем      |    domain    | CartConfirmed                            |
| Инициирование оплаты заказа        |    domain    | PaymentInitiated                         |
| Резервирование товаров успешно     |    domain    | StockReserved                            |
| Резервирование товаров не успешно  |   failure    | StockReservationFailed                   |
| Списание средств успешно           |    domain    | PaymentSucceeded                         |
| Списание средств не успешно        |   failure    | PaymentFailed                            |
| Оплата отменена        |   domain    | PaymentCancelled                            |
| Сформирована заявка на доставку    |    domain    | DeliveryScheduled                        |
| Заявка на доставку не сформирована | compensation | DeliverySchedulingFailed                 |
| Уведомление продавцу о подготовке товара | domain | SellerNotifiedForDispatch                |
| Уведомление покупателю об успешном оформлении | domain | BuyerNotifiedOrderConfirmed         |
| Продавец окончательно подтвердил заказ | domain   | SellerConfirmedDeliveryOrder        |
| Подтверждение заказа покупателем   |    domain    | OrderConfirmed                      |
| Заказ отменён покупателем          | compensation | BuyerCanceledOrder                  |
| Заказ отменён автоматически | compensation | OrderAutomaticallyCanceled |
| Заказ не подтверждён покупателем   |   timeout    | OrderConfirmTimeout                 |
| Заказ отменён продавцом            | compensation | SellerCanceledOrder                 |
| Отмена резервирования товара       | compensation | CancelReservation                 |
| Отмена оплаты товара       | compensation | CancelPayment                 |
| Не удалось осуществить доставку    | compensation | DeliveryFailed                 |

## События при просмотре заказа покупателем ##

*TODO*

## События при просмотре заказа продавцом ##

*TODO*