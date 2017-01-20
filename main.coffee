
bus = new Vue()

store = {
  debug: true,
  state: {
    errMsg:'',
    errTitle:'',
    hasErr:false,
    user:null,
  },

  set: (k,v) -> 
  	console.log("sotre action$set: k => #{k}, v => #{v}") if this.debug
  	this.state[k] = v
  	this

  get: (k) ->
  	console.log ("sotre action$get: k => #{k}, v => #{this.state[k]}") if this.debug
  	this.state[k]
}

loginPage = {
	name: 'login_page',
	data: () -> {
		'email': '',
		'password': '',
		'passwordAgain': '',
		'isRegister': false,
	}
	methods: {
		'showAlert': (msg,title='Warning') ->
			alert 'showAlert'
			this.$parent.errMsg = msg
			this.$parent.errTitle = title
			this.$parent.hasErr = true

		'registerWithEmail': (event) ->
			if not this.isRegister
				this.isRegister = true
			else
				if this.password == this.passwordAgain
					firebase.auth().createUserWithEmailAndPassword(this.email, this.password).catch((error) -> this.showAlert("Error Happened:\n#{error.code},\n#{error.message}"))
				else
					this.showAlert 'Need same passwords'

		'withEmail': (event) -> 
			firebase.auth().signInWithEmailAndPassword(this.email, this.password).catch((error) -> 
																							this.showAlert error.message,'Login Error')

		'withTPL': (type) -> 
			Err = (error) -> this.showAlert error.message,'Login Error'
			if type == 'google'
				firebase.auth()
	}
	template: '<div class="container">

      <form class="form-signin" v-on:submit.stop.prevent>
        <h2 class="form-signin-heading">Please Enter</h2>
        <label for="inputEmail" class="sr-only">Email address</label>
        <input type="email" id="inputEmail" class="form-control" placeholder="Email address" v-model.lazy="email" required autofocus>
        <label for="inputPassword" class="sr-only">Password</label>
        <input type="password" id="inputPassword" class="form-control" placeholder="Password" v-model.trim="password" required>
        <label for="inputPasswordAgain" class="sr-only">Password again</label>
        <input v-if="isRegister" type="password" id="inputPasswordAgain" class="form-control" placeholder="Password again" v-model.trim="passwordAgain" required>
        <button class="btn btn-lg btn-primary btn-block" v-on:click="withEmail" v-if="!isRegister">Sign in</button>
        <button class="btn btn-lg btn-secondary btn-block" v-on:click="registerWithEmail" >Sign up</button>
        <div id="id_thirdparty">
        <div class="dropdown">
  <button class="btn btn-lg btn-block btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    Third Party Login
  </button>
  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
    <a class="dropdown-item" v-on:click="withTPL(\'google\')">Google</a>
    <a class="dropdown-item" v-on:click="withTPL(\'github\')">GitHub</a>
    <a class="dropdown-item" v-on:click="withTPL(\'twitter\')">Twitter</a>
  </div>
</div>
      </div>
      </form>'
}


jumpOutPage = {
	name:"jump_out_page"
	data:() -> {
		'querySet': this.$router.currentRoute.query,
		'isProgress':false
	}
	computed:{
		'user': {
			'get': () -> store.get('user')
			'set': (v) -> store.set('user',v)
		}
		'token': () -> this.user.getToken()
		'username': () -> this.user.displayName
		'avatarUrl': () -> this.user.photoUrl
	}
	methods:{
		'showAlert': (msg,title='Warning') ->
			alert 'showAlert'
			this.$parent.errMsg = msg
			this.$parent.errTitle = title
			this.$parent.hasErr = true

		'toggleButton': () -> 
			b = $('id_jumpButton')
			if b.hasClass('disabled')
				b.removeClass('disabled')
			else
				b.addClass('disabled')

		'jumpOut': () -> 
			this.isProgress = true
			this.toggleButton()
			$.post({
				'url': this.querySet.callback
				'data': {
					'token': this.token,
					'username': this.username,
					'avatarUrl': this.avatarUrl,
				}
				'dataType': 'application/json'
			}).done((data) -> 
						window.location.href=data.jumpUrl
						(window.event.returnValue = false) if window.event)
			.fail((error) ->
						console.log 'Error Happened:'
						$.each(error,(k,v) -> console.log "Error: k => #{k}, v=> #{v}")
						this.showAlert 'Login Failed. Please check callback url.')
	}
	template: '<div class="container">
	<div class="card">
	  <div class="card-block">
	    <h2 class="card-title"> {{ user.displayName }} </h2>
	    <h4 class="card-subtitle mb-2 text-muted"> Are you sure to share your infomation with {{ querySet.appName }}? </h4>
	    <p class="card-text"> These infomation will get by it: </p>
	    </div>
	  <ul class="list-group list-group-flush">
	    <li class="list-group-item"> Indicate your identity </li>
	    <li class="list-group-item"> Get your username </li>
	    <li class="list-group-item"> Get your avatar </li>
	  <div class="card-block">
	    <p class="card-text text-muted">Once you continue, you will be redirected to <code>{{ querySet.callback }}</code></p>
	    <h6 class="card-subtitle">Continue or Not?</h6>
	    <button type="button" id="id_jumpButton" class="btn btn-outline-primary btn-lg" v-on:click="jumpOut">Continue</button>
	    <p class="card-text" v-if="isProgress">Please wait...</p>
	    </div>
	  </div>
	</div>
	'
}


Vue.use(VueRouter)


router = new VueRouter({
	routes: [{
		path: '/login',
		component: loginPage
	},
	{
		path: '/',
		redirect: '/login'
	},
	{
		path: '/jumpout'
		component: jumpOutPage
	}
	]
})

# Test Example:
# ?appName=TestApp&callback=http://localhost:6000/callback
vm = new Vue({
	'data':{
		'sharedState':store
	}
	'computed':{
		'user':{
			get:() -> this._user
			set:(value) ->
				this._user = value
		},
		'errMsg':{
			get: () -> this.sharedState.get('errMsg')
			set: (value) -> 
				this.sharedState.set('errMsg',value)
		},
		'errTitle':{
			get: () -> this.sharedState.get('errTitle')
			set: (value) -> 
				this.sharedState.set('errTitle',value)
		},
		'hasErr':{
			get: () -> this.sharedState.get('hasErr')
			set: (value) -> 
				this.sharedState.set('hasErr',value)
		},
		'user':{
			get:() -> this.sharedState.get('user')
			set:(value) -> this.sharedState.set('user',value)
		}
	}
	'methods':{
		'showAlert': (msg,title='Warning') ->
			alert 'showAlert'
			this.errTitle = title
			this.errMsg = msg
			this.hasErr = true

		'onAuthStateChanged': (user) ->
			console.log('AuthStateChanged')
			if user
				this.user = user
				router.push({
				'path': 'jumpout',
				'query': {
					'appName': this.$router.currentRoute.query.appName,
					'callback': this.$router.currentRoute.query.callback
				}})

			else
				this.showAlert 'User was sign out.'

	}
	'router':router
}).$mount('#app')

firebase.auth().onAuthStateChanged vm.onAuthStateChanged # set Listener

