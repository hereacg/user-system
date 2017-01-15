// Generated by CoffeeScript 1.12.2
var bus, jumpOutPage, loginPage, router, store, vm;

bus = new Vue();

store = {
  debug: true,
  state: {
    errMsg: '',
    errTitle: '',
    hasErr: false,
    user: null
  },
  set: function(k, v) {
    if (this.debug) {
      console.log("sotre action$set: k => " + k + ", v => " + v);
    }
    this.state[k] = v;
    return this;
  },
  get: function(k) {
    if (this.debug) {
      console.log("sotre action$get: k => " + k + ", v => " + this.state[k]);
    }
    return this.state[k];
  }
};

loginPage = {
  name: 'login_page',
  data: function() {
    return {
      'email': '',
      'password': '',
      'passwordAgain': '',
      'isRegister': false
    };
  },
  methods: {
    'showAlert': function(msg, title) {
      if (title == null) {
        title = 'Warning';
      }
      alert('showAlert');
      this.$parent.errMsg = msg;
      this.$parent.errTitle = title;
      return this.$parent.hasErr = true;
    },
    'registerWithEmail': function(event) {
      if (!this.isRegister) {
        return this.isRegister = true;
      } else {
        if (this.password === this.passwordAgain) {
          return firebase.auth().createUserWithEmailAndPassword(this.email, this.password)["catch"](function(error) {
            return this.showAlert("Error Happened:\n" + error.code + ",\n" + error.message);
          });
        } else {
          return this.showAlert('Need same passwords');
        }
      }
    },
    'withEmail': function(event) {
      return firebase.auth().signInWithEmailAndPassword(this.email, this.password)["catch"](function(error) {
        return this.showAlert(error.message, 'Login Error');
      });
    },
    'withTPL': function(type) {
      var Err;
      Err = function(error) {
        return this.showAlert(error.message, 'Login Error');
      };
      if (type === 'google') {
        return firebase.auth();
      }
    }
  },
  template: '<div class="container"> <form class="form-signin" v-on:submit.stop.prevent> <h2 class="form-signin-heading">Please Enter</h2> <label for="inputEmail" class="sr-only">Email address</label> <input type="email" id="inputEmail" class="form-control" placeholder="Email address" v-model.lazy="email" required autofocus> <label for="inputPassword" class="sr-only">Password</label> <input type="password" id="inputPassword" class="form-control" placeholder="Password" v-model.trim="password" required> <label for="inputPasswordAgain" class="sr-only">Password again</label> <input v-if="isRegister" type="password" id="inputPasswordAgain" class="form-control" placeholder="Password again" v-model.trim="passwordAgain" required> <button class="btn btn-lg btn-primary btn-block" v-on:click="withEmail">Sign in</button> <button class="btn btn-lg btn-secondary btn-block" v-on:click="registerWithEmail" >Sign up</button> <div id="id_thirdparty"> <div class="dropdown"> <button class="btn btn-lg btn-block btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"> Third Party Login </button> <div class="dropdown-menu" aria-labelledby="dropdownMenuButton"> <a class="dropdown-item" v-on:click="withTPL(\'google\')">Google</a> <a class="dropdown-item" v-on:click="withTPL(\'github\')">GitHub</a> <a class="dropdown-item" v-on:click="withTPL(\'twitter\')">Twitter</a> </div> </div> </div> </form>'
};

jumpOutPage = {
  name: "jump_out_page",
  data: function() {
    return {
      'querySet': this.$router.currentRoute.query
    };
  },
  computed: {
    'user': {
      'get': function() {
        return store.get('user');
      },
      'set': function(v) {
        return store.set('user', v);
      }
    },
    'token': function() {
      return this.user.getToken();
    },
    'username': function() {
      return this.user.displayName;
    },
    'avatarUrl': function() {
      return this.user.photoUrl;
    }
  },
  methods: {
    'jumpOut': function() {
      return $.post({
        'url': this.querySet.callback,
        'data': {
          'token': this.token,
          'username': this.username,
          'avatarUrl': this.avatarUrl
        },
        'dataType': 'application/json'
      }).done(function(data) {
        window.location.href = data.jumpUrl;
        if (window.event) {
          return window.event.returnValue = false;
        }
      });
    }
  },
  template: '<div class="container"> <div class="card"> <div class="card-block"> <h2 class="card-title"> {{ user.displayName }} </h2> <h4 class="card-subtitle mb-2 text-muted"> Are you sure to share your infomation with {{ querySet.appName }}? </h4> <p class="card-text"> These infomation will get by it: </p> </div> <ul class="list-group list-group-flush"> <li class="list-group-item"> Indicate your identity </li> <li class="list-group-item"> Get your username </li> <li class="list-group-item"> Get your avatar </li> <div class="card-block"> <p class="card-text text-muted">Once you continue, you will be redirected to {{ querySet.callback }}</p> <h6 class="card-subtitle">Continue or Not?</h6> <button class="btn btn-lg" v-on:click="jumpOut">Continue</button> </div> </div> </div>'
};

Vue.use(VueRouter);

router = new VueRouter({
  routes: [
    {
      path: '/login',
      component: loginPage
    }, {
      path: '/',
      redirect: '/login'
    }, {
      path: '/jumpout',
      component: jumpOutPage
    }
  ]
});

vm = new Vue({
  'data': {
    'sharedState': store
  },
  'computed': {
    'user': {
      get: function() {
        return this._user;
      },
      set: function(value) {
        return this._user = value;
      }
    },
    'errMsg': {
      get: function() {
        return this.sharedState.get('errMsg');
      },
      set: function(value) {
        return this.sharedState.set('errMsg', value);
      }
    },
    'errTitle': {
      get: function() {
        return this.sharedState.get('errTitle');
      },
      set: function(value) {
        return this.sharedState.set('errTitle', value);
      }
    },
    'hasErr': {
      get: function() {
        return this.sharedState.get('hasErr');
      },
      set: function(value) {
        return this.sharedState.set('hasErr', value);
      }
    },
    'user': {
      get: function() {
        return this.sharedState.get('user');
      },
      set: function(value) {
        return this.sharedState.set('user', value);
      }
    }
  },
  'methods': {
    'showAlert': function(msg, title) {
      if (title == null) {
        title = 'Warning';
      }
      alert('showAlert');
      this.errTitle = title;
      this.errMsg = msg;
      return this.hasErr = true;
    },
    'onAuthStateChanged': function(user) {
      console.log('AuthStateChanged');
      if (user) {
        this.user = user;
        return router.push({
          'path': 'jumpout',
          'query': {
            'appName': this.$router.currentRoute.query.appName,
            'callback': this.$router.currentRoute.query.callback
          }
        });
      } else {
        return this.showAlert('User was sign out.');
      }
    }
  },
  'router': router
}).$mount('#app');

firebase.auth().onAuthStateChanged(vm.onAuthStateChanged);
