function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = {count: 20, interval: 30000}
  karate.configure('retry', retryConfig)

  var env = karate.env;
  var testTenant = karate.properties['testTenant'];

  var config = {
    tenantParams: {loadReferenceData: true},
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},

    testTenant: testTenant ? testTenant : 'testTenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),

    // define global functions
    setSystemProperty: function (name, property) {
      java.lang.System.setProperty(name, property);
    },
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },
    random: function (max) {
      return Math.floor(Math.random() * 100)
    },
    addVariables: function (a, b) {
      return a + b;
    },
    pause: function (millis) {
      var Thread = Java.type('java.lang.Thread');
      Thread.sleep(millis);
    },
    randomString: function(length) {
      var result = '';
      var characters = 'abcdefghijklmnopqrstuvwxyz';
      var charactersLength = characters.length;
      for ( var i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
      }
      return result;
    }
  };

  config.getModuleByIdPath = '_/proxy/tenants/' + config.admin.tenant + '/modules';

  if (env === 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
  } else if (env === 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-snapshot.dev.folio.org:8000';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
  } else if (env != null && env.match(/^ec2-\d+/)) {
    config.baseUrl = 'http://' + env + ':9130';
    config.admin = {tenant: 'supertenant', name: 'admin', password: 'admin'}
  }

  var params = JSON.parse(JSON.stringify(config.admin))
  params.baseUrl = config.baseUrl;
  var response = karate.callSingle('classpath:common/login.feature', params)
  config.adminToken = response.responseHeaders['x-okapi-token'][0]

//   uncomment to run on local
//   karate.callSingle('classpath:folijet/data-import/global/add-okapi-permissions.feature', config);

  return config;
}

