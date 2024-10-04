package main

import (
	"encoding/json"
	"fmt"
	"os"
	"time"
)

// TODO:
// - unit tests
// - take the interval as a parameter using flag.FlagSet
// - take the "config" file as a parameter
// - count how many intervals we did today

const (
	MOUSE_CLICKED     = "BLOCK_BUTTON"
	MOUSE_LEFT        = "1" // Start/Pause
	MOUSE_MID         = "2"
	MOUSE_RIGHT       = "3" // Stop/Cancel
	MOUSE_SCROLL_UP   = "4" // Increase timer
	MOUSE_SCROLL_DOWN = "5" // Decrease timer

	// confFile        = "~/.pomo-go.json"
	confFile        = "./pomo-go.json"
	defaultDuration = time.Minute * 25
)

func help() {
	fmt.Printf("%s \n", os.Args[0])
	fmt.Printf("\t-i <interval>\n")
}

type Config struct {
	TimeStart       time.Time     `json:"time_start"`
	DurationMinutes time.Duration `json:"duration_minutes"`
}

func displayStatus(cfg *Config) {
	timePassed := time.Now().Sub(cfg.TimeStart)
	z := time.Unix(0, 0).UTC()
	timeString := z.Add(time.Duration(timePassed)).Format("15:04:05")
	fmt.Printf("%s\n", timeString)
}

func loadConfig(confFile string) (*Config, error) {
	cfgData, err := os.ReadFile(confFile)
	if err != nil {
		return nil, fmt.Errorf("unable to read config %w", err)
	}

	cfg := &Config{}

	err = json.Unmarshal(cfgData, cfg)
	if err != nil {
		return nil, fmt.Errorf("unable to parse config %w", err)
	}

	return cfg, nil
}

func createConfig(duration time.Duration) (*Config, error) {
	newCfg := &Config{
		TimeStart:       time.Now(),
		DurationMinutes: duration,
	}

	serialized, err := json.MarshalIndent(newCfg, "", "    ")
	if err != nil {
		return nil, fmt.Errorf("unable to serialize config %w", err)
	}

	err = os.WriteFile(confFile, serialized, 0644)
	if err != nil {
		return nil, fmt.Errorf("unable to write file %q %w", confFile, err)
	}

	return newCfg, nil
}

func main() {
	var err error
	var cfg *Config
	// help()

	mouseBtn, ok := os.LookupEnv(MOUSE_CLICKED)
	if !ok {
		// No mouse button has been clicked, just show how long has passed since start
		cfg, err := loadConfig(confFile)
		if err == nil {
			displayStatus(cfg)
			return
		}

		return
	}

	switch mouseBtn {
	case MOUSE_LEFT:
		cfg, err = createConfig(defaultDuration)
	case MOUSE_MID:
	case MOUSE_RIGHT:
		// remove config
	case MOUSE_SCROLL_UP:
		// edit default value in config
	case MOUSE_SCROLL_DOWN:
		// edit default value in config
	default:
		err = fmt.Errorf("unknown value for %q = %q", MOUSE_CLICKED, mouseBtn)
	}

	if err != nil {
		panic(err)
	}

	displayStatus(cfg)
}
