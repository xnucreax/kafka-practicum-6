package main

import (
	"context"
	"log"
	"math/rand"
	"os"
	"os/signal"
	"syscall"

	"kafka/internal"
)

func main() {
	bootstrapServers := os.Getenv("KAFKA_BOOTSTRAP")
	topic := os.Getenv("KAFKA_TOPIC")

	if bootstrapServers == "" || topic == "" {
		log.Fatal("KAFKA_BOOTSTRAP and KAFKA_TOPIC env vars are required")
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	producerId := rand.Int() % 1000
	if err := internal.RunProducer(ctx, internal.ProducerParams{
		BootstrapServers: bootstrapServers,
		Topic:            topic,
		Id:               producerId,
	}); err != nil {
		log.Fatalf("failed to start producer: %v", err)
	}

	if err := internal.RunSingleMessageConsumer(ctx, internal.SingleMessageConsumerParams{
		BootstrapServers: bootstrapServers,
		GroupID:          "single-consumer-group",
		Topic:            topic,
	}); err != nil {
		log.Fatalf("failed to start single consumer: %v", err)
	}

	if err := internal.RunBatchMessageConsumer(ctx, internal.BatchMessageConsumerParams{
		BootstrapServers: bootstrapServers,
		GroupID:          "batch-consumer-group",
		Topic:            topic,
	}); err != nil {
		log.Fatalf("failed to start batch consumer: %v", err)
	}

	sigchan := make(chan os.Signal, 1)
	signal.Notify(sigchan, syscall.SIGINT, syscall.SIGTERM)
	sig := <-sigchan
	log.Printf("received signal %v, shutting down", sig)
	cancel()
}
