package synapse

import (
	"github.com/confluentinc/confluent-kafka-go/kafka"
)

type Consumer struct {
	kc *kafka.Consumer
}

func NewConsumer() (c *Consumer, err error) {
	kc, err := kafka.NewConsumer(&kafka.ConfigMap{
		"bootstrap.servers": "localhost",
		"group.id":          "myGroup",
		"auto.offset.reset": "earliest",
	})
	if err != nil {
		return
	}
	err = kc.SubscribeTopics([]string{
		"players",
		"sessions",
	}, nil)
	if err != nil {
		return
	}
	c = &Consumer{
		kc: kc,
	}
	return
}
func (c *Consumer) Close() { c.Close() }

func (c *Consumer) Read() (topic string, key, value []byte, err error) {
	km, err := c.kc.ReadMessage(-1)
	if err != nil {
		return
	}
	topic = *km.TopicPartition.Topic
	key = km.Key
	value = km.Value
	err = km.TopicPartition.Error
	return
}
