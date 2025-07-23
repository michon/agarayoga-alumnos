// app/javascript/channels/index.js
import { createConsumer } from "@rails/actioncable";
export default createConsumer();

// Opcional: Si necesitas importar canales específicos
const channelContext = require.context('.', true, /_channel\.js$/);
channelContext.keys().forEach(channelContext);
