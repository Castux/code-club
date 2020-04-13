class MyWorkletProcessor extends AudioWorkletProcessor
{
    constructor()
    {
        super();

        this.port.onmessage = (event) => {
            console.log(event.data);
        };
    }

    process(inputs, outputs, parameters)
    {
    }
}

registerProcessor('my-worklet-processor', MyWorkletProcessor);
