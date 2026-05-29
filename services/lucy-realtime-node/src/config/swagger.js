const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Lucy Realtime Node API',
      version: '1.0.0',
      description: 'Realtime socket and room API for Lucy.',
    },
    servers: [
      {
        url: `http://localhost:${process.env.PORT || 3004}`,
      },
    ],
  },
  apis: ['./src/routes/*.js', './src/controllers/*.js'],
};

module.exports = swaggerJsdoc(options);
