*Данный файл сгенерирован с помощью ИИ для описания артефактов проделанной работы*

### Название задачи: Реестр архитектурных решений и связанных документов NovaMarket (Task1)


**Автор:** Иван Бабиков
**Дата:** 16.09.2026

---

### Назначение

Индекс-карта (decision log) для навигации по архитектурным решениям и их детализации. Помогает видеть, что в `Task1` являются **решениями** (ADR), а что — **детализацией** (design-docs, реестры, диаграммы).

---

### Архитектурные решения (ADR)

| ID | Решение | Статус | Дата | Связанная детализация |
|:--|:--|:--|:--|:--|
| [ADR-01](ADR-01-microservices.md) | Старт с микросервисной архитектуры | **Принят** | 14.09.2026 | [Обзор архитектуры (C2)](C2-architecture-overview.md) |
| [ADR-02](ADR-02-SAGA-pattern-choice.md) | Выбор SAGA-хореографии на Kafka | **Принят** | 14.09.2026 | [Реестр событий](saga-events-registry.md), [Сценарии и компенсации](saga-choreography-flow.md) |

> ADR — это записи **решений** (контекст, альтернативы, выбор, риски). Дальнейшие архитектурные решения нумеруются с ADR-03.

---

### Детализация и дизайн-документы (не ADR)

| Документ | Тип | Описывает |
|:--|:--|:--|
| [C2-architecture-overview.md](C2-architecture-overview.md) | Дизайн-документ (C4 Container) | Статическая структура из [C2.puml](C2.puml) |
| [saga-choreography-flow.md](saga-choreography-flow.md) | Дизайн-документ (последовательности) | Happy path и все сценарии отказа/компенсаций |
| [saga-events-registry.md](saga-events-registry.md) | Реестр контрактов | События саги: publisher/type/name |

---

### Диаграммы PlantUML

#### C4

| Файл | Описание |
|:--|:--|
| [C2.puml](C2.puml) | Контейнерная диаграмма системы |

#### SAGA-хореография (последовательности)

| Файл | Сценарий |
|:--|:--|
| [seq-order-placement-choreography-happy-path.puml](seq-order-placement-choreography-happy-path.puml) | Happy path |
| [seq-order-placement-choreography-stock-reservation-failed.puml](seq-order-placement-choreography-stock-reservation-failed.puml) | Отказ резервирования |
| [seq-order-placement-choreography-payment-failed.puml](seq-order-placement-choreography-payment-failed.puml) | Отказ оплаты |
| [seq-order-placement-choreography-delivery-scheduling-failed.puml](seq-order-placement-choreography-delivery-scheduling-failed.puml) | Отказ доставки |
| [seq-order-placement-choreography-buyer-cancel.puml](seq-order-placement-choreography-buyer-cancel.puml) | Отмена покупателем |

#### Сравнительные / прочие (из ADR-02 и ранее)

| Файл | Назначение |
|:--|:--|
| [seq-order-placement-orchestration.puml](seq-order-placement-orchestration.puml) | Вариант «оркестрация» (альтернатива из ADR-02) |
| [seq-order-placement-detailed.puml](seq-order-placement-detailed.puml) | Упрощенная (не SAGA) последовательность оформления заказа |

---

### Статус

**Принят** (индексный документ, не является решением).