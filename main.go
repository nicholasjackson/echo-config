package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/hashicorp/go-hclog"
)

var configLocation = flag.String("config-file", "./config.json", "Location of the application config file")
var config *Config = &Config{}
var log hclog.Logger

type Config struct {
	APIKey       string        `json:"api_key"`
	DBConnection string        `json:"db_connection"`
	Timeout      time.Duration `json:"timeout"`
}

func main() {
	log = hclog.Default()
	log.Info("Starting application")

	flag.Parse()

	// initially load the config
	loadConfig()

	// handle updates to the config
	go handleConfigUpdates()

	http.HandleFunc("/config", configHandler)
	http.ListenAndServe(":9090", nil)
}

func loadConfig() error {
	log.Info("Load config", "file", *configLocation)

	// read the config file
	f, err := os.Open(*configLocation)
	if err != nil {
		return fmt.Errorf("unable to open config: %s", err)
	}

	d := json.NewDecoder(f)
	err = d.Decode(config)
	if err != nil {
		return fmt.Errorf("unable to decode config: %s", err)
	}

	return nil
}

func handleConfigUpdates() {
	sigs := make(chan os.Signal)
	signal.Notify(sigs, syscall.SIGHUP)

	for {
		<-sigs

		log.Info("Received SIGHUP")
		loadConfig()
	}
}

func configHandler(rw http.ResponseWriter, r *http.Request) {
	e := json.NewEncoder(rw)

	e.Encode(config)
}
