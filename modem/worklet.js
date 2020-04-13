class DPSKEncoder extends AudioWorkletProcessor
{
    constructor()
    {
        super();

        this.samples_per_symbols = 100;
        this.sample_index = 0;
        this.queue = [];

        this.port.onmessage = (event) =>
        {
            var cmd = event.data.cmd;
            var data = event.data.data;

            switch(cmd)
            {
                case "symbols":
                    this.queue = this.queue.concat(data);
                    break;
                case "sps":
                    this.samples_per_symbols = data;
                    break;
            }
        };
    }

    process(inputs, outputs, parameters)
    {
        return true;
    }
}

registerProcessor('dpsk-encoder', DPSKEncoder);
