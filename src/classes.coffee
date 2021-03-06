module.exports =
  _name: "classes"
  _v: 1
  _prio: 700
  _mergers: require("./_merger").copy(source: "classes")
  mixins: [
    require("./class")
    require("./combined")
  ]
  created: ->
    @$combined
      path: "classes"
      value: @classes
      parseProp: @$class.strToObj
      cbFactory: (name) ->[(val) ->@$class.set name, val]


test module.exports, (merge) ->
  describe "ceri", ->
    describe "classes", ->
      el = null
      before (done) ->
        el = makeEl merge 
          mixins: [
            require("./structure")
            require("./props")
          ]
          structure: template(1,"""
            <div #ref="someDiv"></div>
            """)
          data: -> someClass: true
          props:
            class2:
              type: String
          classes:
            this:
              computed: -> someClass: @someClass
              data: -> someDataClass: true
              prop: "class2"
            someDiv:
              data: -> someData2Class: true
        setTimeout done, 100
      after -> el.remove()
          
      it "should work", (done) ->
        el.should.have.attr "class", "someClass someDataClass"
        el.someDiv.should.have.attr "class", "someData2Class"
        el.class2 = "somePropClass"
        el.$nextTick ->
          el.should.have.attr "class", "somePropClass someClass someDataClass"
          el.$nextTick ->
            el.classes.this.someDataClass = false
            el.should.have.attr "class", "somePropClass someClass"
            done()
        
      after ->
        el.remove()
