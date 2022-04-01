package synapse

import (
	"github.com/confluentinc/confluent-kafka-go/kafka"
)

type Producer struct {
	kp *kafka.Producer
}

func NewProducer() (p *Producer, err error) {
	kp, err := kafka.NewProducer(&kafka.ConfigMap{"bootstrap.servers": "localhost"})
	if err != nil {
		return
	}
	p = &Producer{
		kp: kp,
	}
	return
}

func (p *Producer) Close() { p.kp.Close() }

func (p *Producer) Produce(topic string, key, value []byte) (err error) {
	err = p.kp.Produce(&kafka.Message{
		TopicPartition: kafka.TopicPartition{
			Topic:     &topic,
			Partition: kafka.PartitionAny,
		},
		Key:   key,
		Value: value,
	}, nil)
	return
}
