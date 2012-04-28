
bufbomb:     file format elf32-i386


Disassembly of section .init:

080486cc <_init>:
 80486cc:	55                   	push   %ebp
 80486cd:	89 e5                	mov    %esp,%ebp
 80486cf:	83 ec 08             	sub    $0x8,%esp
 80486d2:	e8 01 02 00 00       	call   80488d8 <call_gmon_start>
 80486d7:	e8 5c 02 00 00       	call   8048938 <frame_dummy>
 80486dc:	e8 07 0e 00 00       	call   80494e8 <__do_global_ctors_aux>
 80486e1:	c9                   	leave  
 80486e2:	c3                   	ret    

Disassembly of section .plt:

080486e4 <write@plt-0x10>:
 80486e4:	ff 35 40 a1 04 08    	pushl  0x804a140
 80486ea:	ff 25 44 a1 04 08    	jmp    *0x804a144
 80486f0:	00 00                	add    %al,(%eax)
	...

080486f4 <write@plt>:
 80486f4:	ff 25 48 a1 04 08    	jmp    *0x804a148
 80486fa:	68 00 00 00 00       	push   $0x0
 80486ff:	e9 e0 ff ff ff       	jmp    80486e4 <_init+0x18>

08048704 <close@plt>:
 8048704:	ff 25 4c a1 04 08    	jmp    *0x804a14c
 804870a:	68 08 00 00 00       	push   $0x8
 804870f:	e9 d0 ff ff ff       	jmp    80486e4 <_init+0x18>

08048714 <inet_pton@plt>:
 8048714:	ff 25 50 a1 04 08    	jmp    *0x804a150
 804871a:	68 10 00 00 00       	push   $0x10
 804871f:	e9 c0 ff ff ff       	jmp    80486e4 <_init+0x18>

08048724 <fprintf@plt>:
 8048724:	ff 25 54 a1 04 08    	jmp    *0x804a154
 804872a:	68 18 00 00 00       	push   $0x18
 804872f:	e9 b0 ff ff ff       	jmp    80486e4 <_init+0x18>

08048734 <signal@plt>:
 8048734:	ff 25 58 a1 04 08    	jmp    *0x804a158
 804873a:	68 20 00 00 00       	push   $0x20
 804873f:	e9 a0 ff ff ff       	jmp    80486e4 <_init+0x18>

08048744 <__errno_location@plt>:
 8048744:	ff 25 5c a1 04 08    	jmp    *0x804a15c
 804874a:	68 28 00 00 00       	push   $0x28
 804874f:	e9 90 ff ff ff       	jmp    80486e4 <_init+0x18>

08048754 <random@plt>:
 8048754:	ff 25 60 a1 04 08    	jmp    *0x804a160
 804875a:	68 30 00 00 00       	push   $0x30
 804875f:	e9 80 ff ff ff       	jmp    80486e4 <_init+0x18>

08048764 <puts@plt>:
 8048764:	ff 25 64 a1 04 08    	jmp    *0x804a164
 804876a:	68 38 00 00 00       	push   $0x38
 804876f:	e9 70 ff ff ff       	jmp    80486e4 <_init+0x18>

08048774 <getopt@plt>:
 8048774:	ff 25 68 a1 04 08    	jmp    *0x804a168
 804877a:	68 40 00 00 00       	push   $0x40
 804877f:	e9 60 ff ff ff       	jmp    80486e4 <_init+0x18>

08048784 <__libc_start_main@plt>:
 8048784:	ff 25 6c a1 04 08    	jmp    *0x804a16c
 804878a:	68 48 00 00 00       	push   $0x48
 804878f:	e9 50 ff ff ff       	jmp    80486e4 <_init+0x18>

08048794 <strcat@plt>:
 8048794:	ff 25 70 a1 04 08    	jmp    *0x804a170
 804879a:	68 50 00 00 00       	push   $0x50
 804879f:	e9 40 ff ff ff       	jmp    80486e4 <_init+0x18>

080487a4 <printf@plt>:
 80487a4:	ff 25 74 a1 04 08    	jmp    *0x804a174
 80487aa:	68 58 00 00 00       	push   $0x58
 80487af:	e9 30 ff ff ff       	jmp    80486e4 <_init+0x18>

080487b4 <__strdup@plt>:
 80487b4:	ff 25 78 a1 04 08    	jmp    *0x804a178
 80487ba:	68 60 00 00 00       	push   $0x60
 80487bf:	e9 20 ff ff ff       	jmp    80486e4 <_init+0x18>

080487c4 <srand@plt>:
 80487c4:	ff 25 7c a1 04 08    	jmp    *0x804a17c
 80487ca:	68 68 00 00 00       	push   $0x68
 80487cf:	e9 10 ff ff ff       	jmp    80486e4 <_init+0x18>

080487d4 <exit@plt>:
 80487d4:	ff 25 80 a1 04 08    	jmp    *0x804a180
 80487da:	68 70 00 00 00       	push   $0x70
 80487df:	e9 00 ff ff ff       	jmp    80486e4 <_init+0x18>

080487e4 <calloc@plt>:
 80487e4:	ff 25 84 a1 04 08    	jmp    *0x804a184
 80487ea:	68 78 00 00 00       	push   $0x78
 80487ef:	e9 f0 fe ff ff       	jmp    80486e4 <_init+0x18>

080487f4 <memset@plt>:
 80487f4:	ff 25 88 a1 04 08    	jmp    *0x804a188
 80487fa:	68 80 00 00 00       	push   $0x80
 80487ff:	e9 e0 fe ff ff       	jmp    80486e4 <_init+0x18>

08048804 <connect@plt>:
 8048804:	ff 25 8c a1 04 08    	jmp    *0x804a18c
 804880a:	68 88 00 00 00       	push   $0x88
 804880f:	e9 d0 fe ff ff       	jmp    80486e4 <_init+0x18>

08048814 <fopen@plt>:
 8048814:	ff 25 90 a1 04 08    	jmp    *0x804a190
 804881a:	68 90 00 00 00       	push   $0x90
 804881f:	e9 c0 fe ff ff       	jmp    80486e4 <_init+0x18>

08048824 <srandom@plt>:
 8048824:	ff 25 94 a1 04 08    	jmp    *0x804a194
 804882a:	68 98 00 00 00       	push   $0x98
 804882f:	e9 b0 fe ff ff       	jmp    80486e4 <_init+0x18>

08048834 <sprintf@plt>:
 8048834:	ff 25 98 a1 04 08    	jmp    *0x804a198
 804883a:	68 a0 00 00 00       	push   $0xa0
 804883f:	e9 a0 fe ff ff       	jmp    80486e4 <_init+0x18>

08048844 <socket@plt>:
 8048844:	ff 25 9c a1 04 08    	jmp    *0x804a19c
 804884a:	68 a8 00 00 00       	push   $0xa8
 804884f:	e9 90 fe ff ff       	jmp    80486e4 <_init+0x18>

08048854 <_IO_getc@plt>:
 8048854:	ff 25 a0 a1 04 08    	jmp    *0x804a1a0
 804885a:	68 b0 00 00 00       	push   $0xb0
 804885f:	e9 80 fe ff ff       	jmp    80486e4 <_init+0x18>

08048864 <__ctype_b_loc@plt>:
 8048864:	ff 25 a4 a1 04 08    	jmp    *0x804a1a4
 804886a:	68 b8 00 00 00       	push   $0xb8
 804886f:	e9 70 fe ff ff       	jmp    80486e4 <_init+0x18>

08048874 <rand@plt>:
 8048874:	ff 25 a8 a1 04 08    	jmp    *0x804a1a8
 804887a:	68 c0 00 00 00       	push   $0xc0
 804887f:	e9 60 fe ff ff       	jmp    80486e4 <_init+0x18>

08048884 <alarm@plt>:
 8048884:	ff 25 ac a1 04 08    	jmp    *0x804a1ac
 804888a:	68 c8 00 00 00       	push   $0xc8
 804888f:	e9 50 fe ff ff       	jmp    80486e4 <_init+0x18>

08048894 <cuserid@plt>:
 8048894:	ff 25 b0 a1 04 08    	jmp    *0x804a1b0
 804889a:	68 d0 00 00 00       	push   $0xd0
 804889f:	e9 40 fe ff ff       	jmp    80486e4 <_init+0x18>

080488a4 <strcpy@plt>:
 80488a4:	ff 25 b4 a1 04 08    	jmp    *0x804a1b4
 80488aa:	68 d8 00 00 00       	push   $0xd8
 80488af:	e9 30 fe ff ff       	jmp    80486e4 <_init+0x18>

Disassembly of section .text:

080488b4 <_start>:
 80488b4:	31 ed                	xor    %ebp,%ebp
 80488b6:	5e                   	pop    %esi
 80488b7:	89 e1                	mov    %esp,%ecx
 80488b9:	83 e4 f0             	and    $0xfffffff0,%esp
 80488bc:	50                   	push   %eax
 80488bd:	54                   	push   %esp
 80488be:	52                   	push   %edx
 80488bf:	68 b4 94 04 08       	push   $0x80494b4
 80488c4:	68 84 94 04 08       	push   $0x8049484
 80488c9:	51                   	push   %ecx
 80488ca:	56                   	push   %esi
 80488cb:	68 8c 91 04 08       	push   $0x804918c
 80488d0:	e8 af fe ff ff       	call   8048784 <__libc_start_main@plt>
 80488d5:	f4                   	hlt    
 80488d6:	90                   	nop
 80488d7:	90                   	nop

080488d8 <call_gmon_start>:
 80488d8:	55                   	push   %ebp
 80488d9:	89 e5                	mov    %esp,%ebp
 80488db:	53                   	push   %ebx
 80488dc:	50                   	push   %eax
 80488dd:	e8 00 00 00 00       	call   80488e2 <call_gmon_start+0xa>
 80488e2:	5b                   	pop    %ebx
 80488e3:	81 c3 5a 18 00 00    	add    $0x185a,%ebx
 80488e9:	8b 83 7c 00 00 00    	mov    0x7c(%ebx),%eax
 80488ef:	85 c0                	test   %eax,%eax
 80488f1:	74 02                	je     80488f5 <call_gmon_start+0x1d>
 80488f3:	ff d0                	call   *%eax
 80488f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 80488f8:	c9                   	leave  
 80488f9:	c3                   	ret    
 80488fa:	90                   	nop
 80488fb:	90                   	nop

080488fc <__do_global_dtors_aux>:
 80488fc:	55                   	push   %ebp
 80488fd:	89 e5                	mov    %esp,%ebp
 80488ff:	83 ec 08             	sub    $0x8,%esp
 8048902:	80 3d cc a1 04 08 00 	cmpb   $0x0,0x804a1cc
 8048909:	75 29                	jne    8048934 <__do_global_dtors_aux+0x38>
 804890b:	a1 08 a0 04 08       	mov    0x804a008,%eax
 8048910:	8b 10                	mov    (%eax),%edx
 8048912:	85 d2                	test   %edx,%edx
 8048914:	74 17                	je     804892d <__do_global_dtors_aux+0x31>
 8048916:	89 f6                	mov    %esi,%esi
 8048918:	83 c0 04             	add    $0x4,%eax
 804891b:	a3 08 a0 04 08       	mov    %eax,0x804a008
 8048920:	ff d2                	call   *%edx
 8048922:	a1 08 a0 04 08       	mov    0x804a008,%eax
 8048927:	8b 10                	mov    (%eax),%edx
 8048929:	85 d2                	test   %edx,%edx
 804892b:	75 eb                	jne    8048918 <__do_global_dtors_aux+0x1c>
 804892d:	c6 05 cc a1 04 08 01 	movb   $0x1,0x804a1cc
 8048934:	c9                   	leave  
 8048935:	c3                   	ret    
 8048936:	89 f6                	mov    %esi,%esi

08048938 <frame_dummy>:
 8048938:	55                   	push   %ebp
 8048939:	89 e5                	mov    %esp,%ebp
 804893b:	83 ec 08             	sub    $0x8,%esp
 804893e:	a1 38 a1 04 08       	mov    0x804a138,%eax
 8048943:	85 c0                	test   %eax,%eax
 8048945:	74 19                	je     8048960 <frame_dummy+0x28>
 8048947:	b8 00 00 00 00       	mov    $0x0,%eax
 804894c:	85 c0                	test   %eax,%eax
 804894e:	74 10                	je     8048960 <frame_dummy+0x28>
 8048950:	83 ec 0c             	sub    $0xc,%esp
 8048953:	68 38 a1 04 08       	push   $0x804a138
 8048958:	e8 a3 76 fb f7       	call   0 <_init-0x80486cc>
 804895d:	83 c4 10             	add    $0x10,%esp
 8048960:	c9                   	leave  
 8048961:	c3                   	ret    
 8048962:	90                   	nop
 8048963:	90                   	nop

08048964 <smoke>:
 8048964:	55                   	push   %ebp
 8048965:	89 e5                	mov    %esp,%ebp
 8048967:	83 ec 14             	sub    $0x14,%esp
 804896a:	6a 00                	push   $0x0
 804896c:	e8 33 03 00 00       	call   8048ca4 <entry_check>
 8048971:	c7 04 24 48 95 04 08 	movl   $0x8049548,(%esp)
 8048978:	e8 e7 fd ff ff       	call   8048764 <puts@plt>
 804897d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 8048984:	e8 7f 03 00 00       	call   8048d08 <validate>
 8048989:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 8048990:	e8 3f fe ff ff       	call   80487d4 <exit@plt>
 8048995:	8d 76 00             	lea    0x0(%esi),%esi

08048998 <fizz>:
 8048998:	55                   	push   %ebp
 8048999:	89 e5                	mov    %esp,%ebp
 804899b:	53                   	push   %ebx
 804899c:	83 ec 10             	sub    $0x10,%esp
 804899f:	8b 5d 08             	mov    0x8(%ebp),%ebx
 80489a2:	6a 01                	push   $0x1
 80489a4:	e8 fb 02 00 00       	call   8048ca4 <entry_check>
 80489a9:	83 c4 10             	add    $0x10,%esp
 80489ac:	3b 1d 1c a0 04 08    	cmp    0x804a01c,%ebx
 80489b2:	74 1c                	je     80489d0 <fizz+0x38>
 80489b4:	83 ec 08             	sub    $0x8,%esp
 80489b7:	53                   	push   %ebx
 80489b8:	68 00 97 04 08       	push   $0x8049700
 80489bd:	e8 e2 fd ff ff       	call   80487a4 <printf@plt>
 80489c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 80489c9:	e8 06 fe ff ff       	call   80487d4 <exit@plt>
 80489ce:	89 f6                	mov    %esi,%esi
 80489d0:	83 ec 08             	sub    $0x8,%esp
 80489d3:	53                   	push   %ebx
 80489d4:	68 63 95 04 08       	push   $0x8049563
 80489d9:	e8 c6 fd ff ff       	call   80487a4 <printf@plt>
 80489de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80489e5:	e8 1e 03 00 00       	call   8048d08 <validate>
 80489ea:	eb d6                	jmp    80489c2 <fizz+0x2a>

080489ec <bang>:
 80489ec:	55                   	push   %ebp
 80489ed:	89 e5                	mov    %esp,%ebp
 80489ef:	83 ec 14             	sub    $0x14,%esp
 80489f2:	6a 02                	push   $0x2
 80489f4:	e8 ab 02 00 00       	call   8048ca4 <entry_check>
 80489f9:	a1 2c a0 04 08       	mov    0x804a02c,%eax
 80489fe:	83 c4 10             	add    $0x10,%esp
 8048a01:	3b 05 1c a0 04 08    	cmp    0x804a01c,%eax
 8048a07:	74 1b                	je     8048a24 <bang+0x38>
 8048a09:	83 ec 08             	sub    $0x8,%esp
 8048a0c:	50                   	push   %eax
 8048a0d:	68 81 95 04 08       	push   $0x8049581
 8048a12:	e8 8d fd ff ff       	call   80487a4 <printf@plt>
 8048a17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 8048a1e:	e8 b1 fd ff ff       	call   80487d4 <exit@plt>
 8048a23:	90                   	nop
 8048a24:	83 ec 08             	sub    $0x8,%esp
 8048a27:	50                   	push   %eax
 8048a28:	68 20 97 04 08       	push   $0x8049720
 8048a2d:	e8 72 fd ff ff       	call   80487a4 <printf@plt>
 8048a32:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 8048a39:	e8 ca 02 00 00       	call   8048d08 <validate>
 8048a3e:	eb d7                	jmp    8048a17 <bang+0x2b>

08048a40 <test>:
 8048a40:	55                   	push   %ebp
 8048a41:	89 e5                	mov    %esp,%ebp
 8048a43:	83 ec 14             	sub    $0x14,%esp
 8048a46:	6a 03                	push   $0x3
 8048a48:	c7 45 fc ef be ad de 	movl   $0xdeadbeef,-0x4(%ebp)
 8048a4f:	e8 50 02 00 00       	call   8048ca4 <entry_check>
 8048a54:	e8 57 00 00 00       	call   8048ab0 <getbuf>
 8048a59:	89 c2                	mov    %eax,%edx
 8048a5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8048a5e:	83 c4 10             	add    $0x10,%esp
 8048a61:	3d ef be ad de       	cmp    $0xdeadbeef,%eax
 8048a66:	74 14                	je     8048a7c <test+0x3c>
 8048a68:	83 ec 0c             	sub    $0xc,%esp
 8048a6b:	68 60 97 04 08       	push   $0x8049760
 8048a70:	e8 ef fc ff ff       	call   8048764 <puts@plt>
 8048a75:	83 c4 10             	add    $0x10,%esp
 8048a78:	c9                   	leave  
 8048a79:	c3                   	ret    
 8048a7a:	89 f6                	mov    %esi,%esi
 8048a7c:	3b 15 1c a0 04 08    	cmp    0x804a01c,%edx
 8048a82:	74 10                	je     8048a94 <test+0x54>
 8048a84:	83 ec 08             	sub    $0x8,%esp
 8048a87:	52                   	push   %edx
 8048a88:	68 9f 95 04 08       	push   $0x804959f
 8048a8d:	e8 12 fd ff ff       	call   80487a4 <printf@plt>
 8048a92:	eb e1                	jmp    8048a75 <test+0x35>
 8048a94:	83 ec 08             	sub    $0x8,%esp
 8048a97:	52                   	push   %edx
 8048a98:	68 ba 95 04 08       	push   $0x80495ba
 8048a9d:	e8 02 fd ff ff       	call   80487a4 <printf@plt>
 8048aa2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
 8048aa9:	e8 5a 02 00 00       	call   8048d08 <validate>
 8048aae:	eb c5                	jmp    8048a75 <test+0x35>

08048ab0 <getbuf>:
 8048ab0:	55                   	push   %ebp
 8048ab1:	89 e5                	mov    %esp,%ebp
 8048ab3:	8d 45 e8             	lea    -0x18(%ebp),%eax
 8048ab6:	83 ec 24             	sub    $0x24,%esp
 8048ab9:	50                   	push   %eax
 8048aba:	e8 fd 00 00 00       	call   8048bbc <Gets>
 8048abf:	b8 01 00 00 00       	mov    $0x1,%eax
 8048ac4:	c9                   	leave  
 8048ac5:	c3                   	ret    
 8048ac6:	89 f6                	mov    %esi,%esi

08048ac8 <getbufn>:
 8048ac8:	55                   	push   %ebp
 8048ac9:	89 e5                	mov    %esp,%ebp
 8048acb:	8d 85 f8 fd ff ff    	lea    -0x208(%ebp),%eax
 8048ad1:	81 ec 14 02 00 00    	sub    $0x214,%esp
 8048ad7:	50                   	push   %eax
 8048ad8:	e8 df 00 00 00       	call   8048bbc <Gets>
 8048add:	b8 01 00 00 00       	mov    $0x1,%eax
 8048ae2:	c9                   	leave  
 8048ae3:	c3                   	ret    

08048ae4 <testn>:
 8048ae4:	55                   	push   %ebp
 8048ae5:	89 e5                	mov    %esp,%ebp
 8048ae7:	83 ec 14             	sub    $0x14,%esp
 8048aea:	6a 04                	push   $0x4
 8048aec:	c7 45 fc ef be ad de 	movl   $0xdeadbeef,-0x4(%ebp)
 8048af3:	e8 ac 01 00 00       	call   8048ca4 <entry_check>
 8048af8:	e8 cb ff ff ff       	call   8048ac8 <getbufn>
 8048afd:	89 c2                	mov    %eax,%edx
 8048aff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8048b02:	83 c4 10             	add    $0x10,%esp
 8048b05:	3d ef be ad de       	cmp    $0xdeadbeef,%eax
 8048b0a:	74 14                	je     8048b20 <testn+0x3c>
 8048b0c:	83 ec 0c             	sub    $0xc,%esp
 8048b0f:	68 60 97 04 08       	push   $0x8049760
 8048b14:	e8 4b fc ff ff       	call   8048764 <puts@plt>
 8048b19:	83 c4 10             	add    $0x10,%esp
 8048b1c:	c9                   	leave  
 8048b1d:	c3                   	ret    
 8048b1e:	89 f6                	mov    %esi,%esi
 8048b20:	3b 15 1c a0 04 08    	cmp    0x804a01c,%edx
 8048b26:	74 10                	je     8048b38 <testn+0x54>
 8048b28:	83 ec 08             	sub    $0x8,%esp
 8048b2b:	52                   	push   %edx
 8048b2c:	68 d7 95 04 08       	push   $0x80495d7
 8048b31:	e8 6e fc ff ff       	call   80487a4 <printf@plt>
 8048b36:	eb e1                	jmp    8048b19 <testn+0x35>
 8048b38:	83 ec 08             	sub    $0x8,%esp
 8048b3b:	52                   	push   %edx
 8048b3c:	68 a0 97 04 08       	push   $0x80497a0
 8048b41:	e8 5e fc ff ff       	call   80487a4 <printf@plt>
 8048b46:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
 8048b4d:	e8 b6 01 00 00       	call   8048d08 <validate>
 8048b52:	eb c5                	jmp    8048b19 <testn+0x35>

08048b54 <save_char>:
 8048b54:	55                   	push   %ebp
 8048b55:	8b 0d 30 a0 04 08    	mov    0x804a030,%ecx
 8048b5b:	89 e5                	mov    %esp,%ebp
 8048b5d:	81 f9 ff 03 00 00    	cmp    $0x3ff,%ecx
 8048b63:	53                   	push   %ebx
 8048b64:	8a 5d 08             	mov    0x8(%ebp),%bl
 8048b67:	7f 37                	jg     8048ba0 <save_char+0x4c>
 8048b69:	88 d8                	mov    %bl,%al
 8048b6b:	c0 e8 04             	shr    $0x4,%al
 8048b6e:	0f be c0             	movsbl %al,%eax
 8048b71:	8d 14 49             	lea    (%ecx,%ecx,2),%edx
 8048b74:	8a 80 34 a0 04 08    	mov    0x804a034(%eax),%al
 8048b7a:	88 82 e0 a1 04 08    	mov    %al,0x804a1e0(%edx)
 8048b80:	89 d8                	mov    %ebx,%eax
 8048b82:	83 e0 0f             	and    $0xf,%eax
 8048b85:	81 c2 e0 a1 04 08    	add    $0x804a1e0,%edx
 8048b8b:	8a 80 34 a0 04 08    	mov    0x804a034(%eax),%al
 8048b91:	88 42 01             	mov    %al,0x1(%edx)
 8048b94:	8d 41 01             	lea    0x1(%ecx),%eax
 8048b97:	c6 42 02 20          	movb   $0x20,0x2(%edx)
 8048b9b:	a3 30 a0 04 08       	mov    %eax,0x804a030
 8048ba0:	8b 1c 24             	mov    (%esp),%ebx
 8048ba3:	c9                   	leave  
 8048ba4:	c3                   	ret    
 8048ba5:	8d 76 00             	lea    0x0(%esi),%esi

08048ba8 <save_term>:
 8048ba8:	55                   	push   %ebp
 8048ba9:	a1 30 a0 04 08       	mov    0x804a030,%eax
 8048bae:	89 e5                	mov    %esp,%ebp
 8048bb0:	c6 84 40 e0 a1 04 08 	movb   $0x0,0x804a1e0(%eax,%eax,2)
 8048bb7:	00 
 8048bb8:	c9                   	leave  
 8048bb9:	c3                   	ret    
 8048bba:	89 f6                	mov    %esi,%esi

08048bbc <Gets>:
 8048bbc:	55                   	push   %ebp
 8048bbd:	89 e5                	mov    %esp,%ebp
 8048bbf:	57                   	push   %edi
 8048bc0:	56                   	push   %esi
 8048bc1:	53                   	push   %ebx
 8048bc2:	83 ec 0c             	sub    $0xc,%esp
 8048bc5:	a1 18 a0 04 08       	mov    0x804a018,%eax
 8048bca:	85 c0                	test   %eax,%eax
 8048bcc:	bf 01 00 00 00       	mov    $0x1,%edi
 8048bd1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8048bd8:	8b 75 08             	mov    0x8(%ebp),%esi
 8048bdb:	c7 05 30 a0 04 08 00 	movl   $0x0,0x804a030
 8048be2:	00 00 00 
 8048be5:	75 45                	jne    8048c2c <Gets+0x70>
 8048be7:	90                   	nop
 8048be8:	83 ec 0c             	sub    $0xc,%esp
 8048beb:	ff 35 0c a0 04 08    	pushl  0x804a00c
 8048bf1:	e8 5e fc ff ff       	call   8048854 <_IO_getc@plt>
 8048bf6:	83 c4 10             	add    $0x10,%esp
 8048bf9:	83 f8 ff             	cmp    $0xffffffff,%eax
 8048bfc:	74 1a                	je     8048c18 <Gets+0x5c>
 8048bfe:	83 f8 0a             	cmp    $0xa,%eax
 8048c01:	74 15                	je     8048c18 <Gets+0x5c>
 8048c03:	88 06                	mov    %al,(%esi)
 8048c05:	83 ec 0c             	sub    $0xc,%esp
 8048c08:	0f be c0             	movsbl %al,%eax
 8048c0b:	50                   	push   %eax
 8048c0c:	e8 43 ff ff ff       	call   8048b54 <save_char>
 8048c11:	46                   	inc    %esi
 8048c12:	83 c4 10             	add    $0x10,%esp
 8048c15:	eb d1                	jmp    8048be8 <Gets+0x2c>
 8048c17:	90                   	nop
 8048c18:	c6 06 00             	movb   $0x0,(%esi)
 8048c1b:	e8 88 ff ff ff       	call   8048ba8 <save_term>
 8048c20:	8b 45 08             	mov    0x8(%ebp),%eax
 8048c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048c26:	5b                   	pop    %ebx
 8048c27:	5e                   	pop    %esi
 8048c28:	5f                   	pop    %edi
 8048c29:	c9                   	leave  
 8048c2a:	c3                   	ret    
 8048c2b:	90                   	nop
 8048c2c:	83 ec 0c             	sub    $0xc,%esp
 8048c2f:	ff 35 0c a0 04 08    	pushl  0x804a00c
 8048c35:	e8 1a fc ff ff       	call   8048854 <_IO_getc@plt>
 8048c3a:	83 c4 10             	add    $0x10,%esp
 8048c3d:	83 f8 ff             	cmp    $0xffffffff,%eax
 8048c40:	89 c3                	mov    %eax,%ebx
 8048c42:	74 d4                	je     8048c18 <Gets+0x5c>
 8048c44:	83 f8 0a             	cmp    $0xa,%eax
 8048c47:	74 cf                	je     8048c18 <Gets+0x5c>
 8048c49:	e8 16 fc ff ff       	call   8048864 <__ctype_b_loc@plt>
 8048c4e:	8b 00                	mov    (%eax),%eax
 8048c50:	66 8b 04 58          	mov    (%eax,%ebx,2),%ax
 8048c54:	25 00 10 00 00       	and    $0x1000,%eax
 8048c59:	66 85 c0             	test   %ax,%ax
 8048c5c:	74 ce                	je     8048c2c <Gets+0x70>
 8048c5e:	8d 43 d0             	lea    -0x30(%ebx),%eax
 8048c61:	83 f8 09             	cmp    $0x9,%eax
 8048c64:	89 c2                	mov    %eax,%edx
 8048c66:	76 0e                	jbe    8048c76 <Gets+0xba>
 8048c68:	8d 43 bf             	lea    -0x41(%ebx),%eax
 8048c6b:	83 f8 05             	cmp    $0x5,%eax
 8048c6e:	8d 53 c9             	lea    -0x37(%ebx),%edx
 8048c71:	76 03                	jbe    8048c76 <Gets+0xba>
 8048c73:	8d 53 a9             	lea    -0x57(%ebx),%edx
 8048c76:	85 ff                	test   %edi,%edi
 8048c78:	75 21                	jne    8048c9b <Gets+0xdf>
 8048c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8048c7d:	c1 e0 04             	shl    $0x4,%eax
 8048c80:	01 d0                	add    %edx,%eax
 8048c82:	88 06                	mov    %al,(%esi)
 8048c84:	83 ec 0c             	sub    $0xc,%esp
 8048c87:	0f be c0             	movsbl %al,%eax
 8048c8a:	50                   	push   %eax
 8048c8b:	e8 c4 fe ff ff       	call   8048b54 <save_char>
 8048c90:	46                   	inc    %esi
 8048c91:	bf 01 00 00 00       	mov    $0x1,%edi
 8048c96:	83 c4 10             	add    $0x10,%esp
 8048c99:	eb 91                	jmp    8048c2c <Gets+0x70>
 8048c9b:	31 ff                	xor    %edi,%edi
 8048c9d:	89 55 f0             	mov    %edx,-0x10(%ebp)
 8048ca0:	eb 8a                	jmp    8048c2c <Gets+0x70>
 8048ca2:	89 f6                	mov    %esi,%esi

08048ca4 <entry_check>:
 8048ca4:	55                   	push   %ebp
 8048ca5:	89 e5                	mov    %esp,%ebp
 8048ca7:	8b 45 08             	mov    0x8(%ebp),%eax
 8048caa:	a3 58 a0 04 08       	mov    %eax,0x804a058
 8048caf:	c9                   	leave  
 8048cb0:	c3                   	ret    
 8048cb1:	8d 76 00             	lea    0x0(%esi),%esi

08048cb4 <writen>:
 8048cb4:	55                   	push   %ebp
 8048cb5:	89 e5                	mov    %esp,%ebp
 8048cb7:	57                   	push   %edi
 8048cb8:	56                   	push   %esi
 8048cb9:	53                   	push   %ebx
 8048cba:	83 ec 0c             	sub    $0xc,%esp
 8048cbd:	8b 7d 10             	mov    0x10(%ebp),%edi
 8048cc0:	85 ff                	test   %edi,%edi
 8048cc2:	8b 75 0c             	mov    0xc(%ebp),%esi
 8048cc5:	89 fb                	mov    %edi,%ebx
 8048cc7:	75 0b                	jne    8048cd4 <writen+0x20>
 8048cc9:	89 f8                	mov    %edi,%eax
 8048ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048cce:	5b                   	pop    %ebx
 8048ccf:	5e                   	pop    %esi
 8048cd0:	5f                   	pop    %edi
 8048cd1:	c9                   	leave  
 8048cd2:	c3                   	ret    
 8048cd3:	90                   	nop
 8048cd4:	52                   	push   %edx
 8048cd5:	53                   	push   %ebx
 8048cd6:	56                   	push   %esi
 8048cd7:	ff 75 08             	pushl  0x8(%ebp)
 8048cda:	e8 15 fa ff ff       	call   80486f4 <write@plt>
 8048cdf:	83 c4 10             	add    $0x10,%esp
 8048ce2:	85 c0                	test   %eax,%eax
 8048ce4:	7e 0a                	jle    8048cf0 <writen+0x3c>
 8048ce6:	01 c6                	add    %eax,%esi
 8048ce8:	29 c3                	sub    %eax,%ebx
 8048cea:	75 e8                	jne    8048cd4 <writen+0x20>
 8048cec:	eb db                	jmp    8048cc9 <writen+0x15>
 8048cee:	89 f6                	mov    %esi,%esi
 8048cf0:	e8 4f fa ff ff       	call   8048744 <__errno_location@plt>
 8048cf5:	83 38 04             	cmpl   $0x4,(%eax)
 8048cf8:	75 04                	jne    8048cfe <writen+0x4a>
 8048cfa:	31 c0                	xor    %eax,%eax
 8048cfc:	eb e8                	jmp    8048ce6 <writen+0x32>
 8048cfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 8048d03:	eb c6                	jmp    8048ccb <writen+0x17>
 8048d05:	8d 76 00             	lea    0x0(%esi),%esi

08048d08 <validate>:
 8048d08:	55                   	push   %ebp
 8048d09:	89 e5                	mov    %esp,%ebp
 8048d0b:	57                   	push   %edi
 8048d0c:	56                   	push   %esi
 8048d0d:	53                   	push   %ebx
 8048d0e:	81 ec 4c 24 00 00    	sub    $0x244c,%esp
 8048d14:	a1 20 a0 04 08       	mov    0x804a020,%eax
 8048d19:	85 c0                	test   %eax,%eax
 8048d1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
 8048d1e:	0f 84 d8 02 00 00    	je     8048ffc <validate+0x2f4>
 8048d24:	83 fb 04             	cmp    $0x4,%ebx
 8048d27:	0f 87 bf 02 00 00    	ja     8048fec <validate+0x2e4>
 8048d2d:	3b 1d 58 a0 04 08    	cmp    0x804a058,%ebx
 8048d33:	74 17                	je     8048d4c <validate+0x44>
 8048d35:	83 ec 0c             	sub    $0xc,%esp
 8048d38:	68 c0 97 04 08       	push   $0x80497c0
 8048d3d:	e8 22 fa ff ff       	call   8048764 <puts@plt>
 8048d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048d45:	5b                   	pop    %ebx
 8048d46:	5e                   	pop    %esi
 8048d47:	5f                   	pop    %edi
 8048d48:	c9                   	leave  
 8048d49:	c3                   	ret    
 8048d4a:	89 f6                	mov    %esi,%esi
 8048d4c:	b8 44 a0 04 08       	mov    $0x804a044,%eax
 8048d51:	8b 14 98             	mov    (%eax,%ebx,4),%edx
 8048d54:	4a                   	dec    %edx
 8048d55:	85 d2                	test   %edx,%edx
 8048d57:	c7 05 28 a0 04 08 01 	movl   $0x1,0x804a028
 8048d5e:	00 00 00 
 8048d61:	89 14 98             	mov    %edx,(%eax,%ebx,4)
 8048d64:	7e 12                	jle    8048d78 <validate+0x70>
 8048d66:	83 ec 0c             	sub    $0xc,%esp
 8048d69:	68 f3 95 04 08       	push   $0x80495f3
 8048d6e:	e8 f1 f9 ff ff       	call   8048764 <puts@plt>
 8048d73:	83 c4 10             	add    $0x10,%esp
 8048d76:	eb ca                	jmp    8048d42 <validate+0x3a>
 8048d78:	8b 3d 24 a0 04 08    	mov    0x804a024,%edi
 8048d7e:	85 ff                	test   %edi,%edi
 8048d80:	0f 85 57 02 00 00    	jne    8048fdd <validate+0x2d5>
 8048d86:	8b 35 10 a0 04 08    	mov    0x804a010,%esi
 8048d8c:	85 f6                	test   %esi,%esi
 8048d8e:	0f 84 3c 02 00 00    	je     8048fd0 <validate+0x2c8>
 8048d94:	51                   	push   %ecx
 8048d95:	6a 00                	push   $0x0
 8048d97:	6a 01                	push   $0x1
 8048d99:	6a 02                	push   $0x2
 8048d9b:	e8 a4 fa ff ff       	call   8048844 <socket@plt>
 8048da0:	83 c4 10             	add    $0x10,%esp
 8048da3:	85 c0                	test   %eax,%eax
 8048da5:	89 85 c4 db ff ff    	mov    %eax,-0x243c(%ebp)
 8048dab:	0f 88 01 02 00 00    	js     8048fb2 <validate+0x2aa>
 8048db1:	50                   	push   %eax
 8048db2:	8d 45 dc             	lea    -0x24(%ebp),%eax
 8048db5:	50                   	push   %eax
 8048db6:	68 fe 95 04 08       	push   $0x80495fe
 8048dbb:	6a 02                	push   $0x2
 8048dbd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 8048dc4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
 8048dcb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
 8048dd2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 8048dd9:	66 c7 45 d8 02 00    	movw   $0x2,-0x28(%ebp)
 8048ddf:	66 c7 45 da c4 ca    	movw   $0xcac4,-0x26(%ebp)
 8048de5:	e8 2a f9 ff ff       	call   8048714 <inet_pton@plt>
 8048dea:	83 c4 10             	add    $0x10,%esp
 8048ded:	85 c0                	test   %eax,%eax
 8048def:	8d 75 d8             	lea    -0x28(%ebp),%esi
 8048df2:	0f 88 b2 01 00 00    	js     8048faa <validate+0x2a2>
 8048df8:	50                   	push   %eax
 8048df9:	6a 10                	push   $0x10
 8048dfb:	56                   	push   %esi
 8048dfc:	ff b5 c4 db ff ff    	pushl  -0x243c(%ebp)
 8048e02:	e8 fd f9 ff ff       	call   8048804 <connect@plt>
 8048e07:	83 c4 10             	add    $0x10,%esp
 8048e0a:	85 c0                	test   %eax,%eax
 8048e0c:	0f 88 5a 01 00 00    	js     8048f6c <validate+0x264>
 8048e12:	83 ec 08             	sub    $0x8,%esp
 8048e15:	68 0d 96 04 08       	push   $0x804960d
 8048e1a:	8d 85 d8 db ff ff    	lea    -0x2428(%ebp),%eax
 8048e20:	50                   	push   %eax
 8048e21:	e8 0e fa ff ff       	call   8048834 <sprintf@plt>
 8048e26:	5f                   	pop    %edi
 8048e27:	58                   	pop    %eax
 8048e28:	8d bd d8 db ff ff    	lea    -0x2428(%ebp),%edi
 8048e2e:	57                   	push   %edi
 8048e2f:	8d 85 d8 df ff ff    	lea    -0x2028(%ebp),%eax
 8048e35:	50                   	push   %eax
 8048e36:	e8 59 f9 ff ff       	call   8048794 <strcat@plt>
 8048e3b:	59                   	pop    %ecx
 8048e3c:	5e                   	pop    %esi
 8048e3d:	68 7f 95 04 08       	push   $0x804957f
 8048e42:	57                   	push   %edi
 8048e43:	e8 ec f9 ff ff       	call   8048834 <sprintf@plt>
 8048e48:	58                   	pop    %eax
 8048e49:	5a                   	pop    %edx
 8048e4a:	57                   	push   %edi
 8048e4b:	8d bd d8 df ff ff    	lea    -0x2028(%ebp),%edi
 8048e51:	57                   	push   %edi
 8048e52:	e8 3d f9 ff ff       	call   8048794 <strcat@plt>
 8048e57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 8048e5e:	e8 31 fa ff ff       	call   8048894 <cuserid@plt>
 8048e63:	83 c4 10             	add    $0x10,%esp
 8048e66:	85 c0                	test   %eax,%eax
 8048e68:	0f 84 e3 00 00 00    	je     8048f51 <validate+0x249>
 8048e6e:	83 ec 08             	sub    $0x8,%esp
 8048e71:	50                   	push   %eax
 8048e72:	8d 85 c8 db ff ff    	lea    -0x2438(%ebp),%eax
 8048e78:	50                   	push   %eax
 8048e79:	e8 26 fa ff ff       	call   80488a4 <strcpy@plt>
 8048e7e:	83 c4 10             	add    $0x10,%esp
 8048e81:	50                   	push   %eax
 8048e82:	8d bd c8 db ff ff    	lea    -0x2438(%ebp),%edi
 8048e88:	57                   	push   %edi
 8048e89:	68 29 96 04 08       	push   $0x8049629
 8048e8e:	8d 85 d8 db ff ff    	lea    -0x2428(%ebp),%eax
 8048e94:	50                   	push   %eax
 8048e95:	e8 9a f9 ff ff       	call   8048834 <sprintf@plt>
 8048e9a:	5e                   	pop    %esi
 8048e9b:	5f                   	pop    %edi
 8048e9c:	8d bd d8 db ff ff    	lea    -0x2428(%ebp),%edi
 8048ea2:	57                   	push   %edi
 8048ea3:	8d 85 d8 df ff ff    	lea    -0x2028(%ebp),%eax
 8048ea9:	50                   	push   %eax
 8048eaa:	e8 e5 f8 ff ff       	call   8048794 <strcat@plt>
 8048eaf:	6a 00                	push   $0x0
 8048eb1:	68 e0 a1 04 08       	push   $0x804a1e0
 8048eb6:	ff 35 1c a0 04 08    	pushl  0x804a01c
 8048ebc:	53                   	push   %ebx
 8048ebd:	ff 35 20 a0 04 08    	pushl  0x804a020
 8048ec3:	68 2f 3b 00 00       	push   $0x3b2f
 8048ec8:	68 00 98 04 08       	push   $0x8049800
 8048ecd:	57                   	push   %edi
 8048ece:	e8 61 f9 ff ff       	call   8048834 <sprintf@plt>
 8048ed3:	83 c4 28             	add    $0x28,%esp
 8048ed6:	57                   	push   %edi
 8048ed7:	8d bd d8 df ff ff    	lea    -0x2028(%ebp),%edi
 8048edd:	57                   	push   %edi
 8048ede:	31 db                	xor    %ebx,%ebx
 8048ee0:	be ff ff ff ff       	mov    $0xffffffff,%esi
 8048ee5:	e8 aa f8 ff ff       	call   8048794 <strcat@plt>
 8048eea:	fc                   	cld    
 8048eeb:	88 d8                	mov    %bl,%al
 8048eed:	89 f1                	mov    %esi,%ecx
 8048eef:	f2 ae                	repnz scas %es:(%edi),%al
 8048ef1:	f7 d1                	not    %ecx
 8048ef3:	83 c4 0c             	add    $0xc,%esp
 8048ef6:	49                   	dec    %ecx
 8048ef7:	51                   	push   %ecx
 8048ef8:	8d bd d8 df ff ff    	lea    -0x2028(%ebp),%edi
 8048efe:	57                   	push   %edi
 8048eff:	ff b5 c4 db ff ff    	pushl  -0x243c(%ebp)
 8048f05:	e8 aa fd ff ff       	call   8048cb4 <writen>
 8048f0a:	89 c2                	mov    %eax,%edx
 8048f0c:	fc                   	cld    
 8048f0d:	89 f1                	mov    %esi,%ecx
 8048f0f:	88 d8                	mov    %bl,%al
 8048f11:	f2 ae                	repnz scas %es:(%edi),%al
 8048f13:	f7 d1                	not    %ecx
 8048f15:	49                   	dec    %ecx
 8048f16:	83 c4 10             	add    $0x10,%esp
 8048f19:	39 ca                	cmp    %ecx,%edx
 8048f1b:	73 1e                	jae    8048f3b <validate+0x233>
 8048f1d:	83 ec 0c             	sub    $0xc,%esp
 8048f20:	68 20 98 04 08       	push   $0x8049820
 8048f25:	e8 3a f8 ff ff       	call   8048764 <puts@plt>
 8048f2a:	59                   	pop    %ecx
 8048f2b:	ff b5 c4 db ff ff    	pushl  -0x243c(%ebp)
 8048f31:	e8 ce f7 ff ff       	call   8048704 <close@plt>
 8048f36:	e9 38 fe ff ff       	jmp    8048d73 <validate+0x6b>
 8048f3b:	83 ec 0c             	sub    $0xc,%esp
 8048f3e:	68 37 96 04 08       	push   $0x8049637
 8048f43:	e8 1c f8 ff ff       	call   8048764 <puts@plt>
 8048f48:	c7 04 24 60 98 04 08 	movl   $0x8049860,(%esp)
 8048f4f:	eb d4                	jmp    8048f25 <validate+0x21d>
 8048f51:	fc                   	cld    
 8048f52:	be 41 96 04 08       	mov    $0x8049641,%esi
 8048f57:	8d bd c8 db ff ff    	lea    -0x2438(%ebp),%edi
 8048f5d:	b9 01 00 00 00       	mov    $0x1,%ecx
 8048f62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
 8048f64:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
 8048f66:	a4                   	movsb  %ds:(%esi),%es:(%edi)
 8048f67:	e9 15 ff ff ff       	jmp    8048e81 <validate+0x179>
 8048f6c:	50                   	push   %eax
 8048f6d:	68 48 96 04 08       	push   $0x8049648
 8048f72:	68 d2 96 04 08       	push   $0x80496d2
 8048f77:	ff 35 c0 a1 04 08    	pushl  0x804a1c0
 8048f7d:	e8 a2 f7 ff ff       	call   8048724 <fprintf@plt>
 8048f82:	8b 85 c4 db ff ff    	mov    -0x243c(%ebp),%eax
 8048f88:	83 c4 10             	add    $0x10,%esp
 8048f8b:	85 c0                	test   %eax,%eax
 8048f8d:	74 11                	je     8048fa0 <validate+0x298>
 8048f8f:	83 ec 0c             	sub    $0xc,%esp
 8048f92:	ff b5 c4 db ff ff    	pushl  -0x243c(%ebp)
 8048f98:	e8 67 f7 ff ff       	call   8048704 <close@plt>
 8048f9d:	83 c4 10             	add    $0x10,%esp
 8048fa0:	83 ec 0c             	sub    $0xc,%esp
 8048fa3:	6a 01                	push   $0x1
 8048fa5:	e8 2a f8 ff ff       	call   80487d4 <exit@plt>
 8048faa:	50                   	push   %eax
 8048fab:	68 50 96 04 08       	push   $0x8049650
 8048fb0:	eb c0                	jmp    8048f72 <validate+0x26a>
 8048fb2:	52                   	push   %edx
 8048fb3:	68 56 96 04 08       	push   $0x8049656
 8048fb8:	68 d2 96 04 08       	push   $0x80496d2
 8048fbd:	ff 35 c0 a1 04 08    	pushl  0x804a1c0
 8048fc3:	e8 5c f7 ff ff       	call   8048724 <fprintf@plt>
 8048fc8:	83 c4 10             	add    $0x10,%esp
 8048fcb:	eb c2                	jmp    8048f8f <validate+0x287>
 8048fcd:	8d 76 00             	lea    0x0(%esi),%esi
 8048fd0:	83 ec 0c             	sub    $0xc,%esp
 8048fd3:	68 a0 98 04 08       	push   $0x80498a0
 8048fd8:	e9 91 fd ff ff       	jmp    8048d6e <validate+0x66>
 8048fdd:	83 ec 0c             	sub    $0xc,%esp
 8048fe0:	68 63 96 04 08       	push   $0x8049663
 8048fe5:	e9 84 fd ff ff       	jmp    8048d6e <validate+0x66>
 8048fea:	89 f6                	mov    %esi,%esi
 8048fec:	83 ec 0c             	sub    $0xc,%esp
 8048fef:	68 00 99 04 08       	push   $0x8049900
 8048ff4:	e9 44 fd ff ff       	jmp    8048d3d <validate+0x35>
 8048ff9:	8d 76 00             	lea    0x0(%esi),%esi
 8048ffc:	83 ec 0c             	sub    $0xc,%esp
 8048fff:	68 40 99 04 08       	push   $0x8049940
 8049004:	e9 34 fd ff ff       	jmp    8048d3d <validate+0x35>
 8049009:	8d 76 00             	lea    0x0(%esi),%esi

0804900c <usage>:
 804900c:	55                   	push   %ebp
 804900d:	89 e5                	mov    %esp,%ebp
 804900f:	83 ec 10             	sub    $0x10,%esp
 8049012:	ff 75 08             	pushl  0x8(%ebp)
 8049015:	68 80 99 04 08       	push   $0x8049980
 804901a:	e8 85 f7 ff ff       	call   80487a4 <printf@plt>
 804901f:	c7 04 24 69 96 04 08 	movl   $0x8049669,(%esp)
 8049026:	e8 39 f7 ff ff       	call   8048764 <puts@plt>
 804902b:	c7 04 24 c0 99 04 08 	movl   $0x80499c0,(%esp)
 8049032:	e8 2d f7 ff ff       	call   8048764 <puts@plt>
 8049037:	c7 04 24 00 9a 04 08 	movl   $0x8049a00,(%esp)
 804903e:	e8 21 f7 ff ff       	call   8048764 <puts@plt>
 8049043:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 804904a:	e8 85 f7 ff ff       	call   80487d4 <exit@plt>
 804904f:	90                   	nop

08049050 <bushandler>:
 8049050:	55                   	push   %ebp
 8049051:	89 e5                	mov    %esp,%ebp
 8049053:	83 ec 14             	sub    $0x14,%esp
 8049056:	68 40 9a 04 08       	push   $0x8049a40
 804905b:	e8 04 f7 ff ff       	call   8048764 <puts@plt>
 8049060:	c7 04 24 87 96 04 08 	movl   $0x8049687,(%esp)
 8049067:	e8 f8 f6 ff ff       	call   8048764 <puts@plt>
 804906c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 8049073:	e8 5c f7 ff ff       	call   80487d4 <exit@plt>

08049078 <seghandler>:
 8049078:	55                   	push   %ebp
 8049079:	89 e5                	mov    %esp,%ebp
 804907b:	83 ec 14             	sub    $0x14,%esp
 804907e:	68 60 9a 04 08       	push   $0x8049a60
 8049083:	e8 dc f6 ff ff       	call   8048764 <puts@plt>
 8049088:	c7 04 24 87 96 04 08 	movl   $0x8049687,(%esp)
 804908f:	e8 d0 f6 ff ff       	call   8048764 <puts@plt>
 8049094:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 804909b:	e8 34 f7 ff ff       	call   80487d4 <exit@plt>

080490a0 <alarmhandler>:
 80490a0:	55                   	push   %ebp
 80490a1:	89 e5                	mov    %esp,%ebp
 80490a3:	83 ec 10             	sub    $0x10,%esp
 80490a6:	ff 35 5c a0 04 08    	pushl  0x804a05c
 80490ac:	68 a0 9a 04 08       	push   $0x8049aa0
 80490b1:	e8 ee f6 ff ff       	call   80487a4 <printf@plt>
 80490b6:	c7 04 24 87 96 04 08 	movl   $0x8049687,(%esp)
 80490bd:	e8 a2 f6 ff ff       	call   8048764 <puts@plt>
 80490c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 80490c9:	e8 06 f7 ff ff       	call   80487d4 <exit@plt>
 80490ce:	89 f6                	mov    %esi,%esi

080490d0 <illegalhandler>:
 80490d0:	55                   	push   %ebp
 80490d1:	89 e5                	mov    %esp,%ebp
 80490d3:	83 ec 14             	sub    $0x14,%esp
 80490d6:	68 e0 9a 04 08       	push   $0x8049ae0
 80490db:	e8 84 f6 ff ff       	call   8048764 <puts@plt>
 80490e0:	c7 04 24 87 96 04 08 	movl   $0x8049687,(%esp)
 80490e7:	e8 78 f6 ff ff       	call   8048764 <puts@plt>
 80490ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 80490f3:	e8 dc f6 ff ff       	call   80487d4 <exit@plt>

080490f8 <launch>:
 80490f8:	55                   	push   %ebp
 80490f9:	89 e5                	mov    %esp,%ebp
 80490fb:	8d 45 b8             	lea    -0x48(%ebp),%eax
 80490fe:	83 ec 48             	sub    $0x48,%esp
 8049101:	25 f8 ff 3f 00       	and    $0x3ffff8,%eax
 8049106:	03 45 0c             	add    0xc(%ebp),%eax
 8049109:	8d 50 0f             	lea    0xf(%eax),%edx
 804910c:	83 e2 f0             	and    $0xfffffff0,%edx
 804910f:	29 d4                	sub    %edx,%esp
 8049111:	89 e2                	mov    %esp,%edx
 8049113:	51                   	push   %ecx
 8049114:	50                   	push   %eax
 8049115:	68 f4 00 00 00       	push   $0xf4
 804911a:	52                   	push   %edx
 804911b:	e8 d4 f6 ff ff       	call   80487f4 <memset@plt>
 8049120:	a1 14 a0 04 08       	mov    0x804a014,%eax
 8049125:	83 c4 10             	add    $0x10,%esp
 8049128:	85 c0                	test   %eax,%eax
 804912a:	75 19                	jne    8049145 <launch+0x4d>
 804912c:	a1 18 a0 04 08       	mov    0x804a018,%eax
 8049131:	85 c0                	test   %eax,%eax
 8049133:	74 4b                	je     8049180 <launch+0x88>
 8049135:	83 ec 0c             	sub    $0xc,%esp
 8049138:	68 9d 96 04 08       	push   $0x804969d
 804913d:	e8 62 f6 ff ff       	call   80487a4 <printf@plt>
 8049142:	83 c4 10             	add    $0x10,%esp
 8049145:	8b 45 08             	mov    0x8(%ebp),%eax
 8049148:	85 c0                	test   %eax,%eax
 804914a:	74 2c                	je     8049178 <launch+0x80>
 804914c:	e8 93 f9 ff ff       	call   8048ae4 <testn>
 8049151:	a1 28 a0 04 08       	mov    0x804a028,%eax
 8049156:	85 c0                	test   %eax,%eax
 8049158:	74 02                	je     804915c <launch+0x64>
 804915a:	c9                   	leave  
 804915b:	c3                   	ret    
 804915c:	83 ec 0c             	sub    $0xc,%esp
 804915f:	68 87 96 04 08       	push   $0x8049687
 8049164:	e8 fb f5 ff ff       	call   8048764 <puts@plt>
 8049169:	c7 05 28 a0 04 08 00 	movl   $0x0,0x804a028
 8049170:	00 00 00 
 8049173:	83 c4 10             	add    $0x10,%esp
 8049176:	eb e2                	jmp    804915a <launch+0x62>
 8049178:	e8 c3 f8 ff ff       	call   8048a40 <test>
 804917d:	eb d2                	jmp    8049151 <launch+0x59>
 804917f:	90                   	nop
 8049180:	83 ec 0c             	sub    $0xc,%esp
 8049183:	68 ae 96 04 08       	push   $0x80496ae
 8049188:	eb b3                	jmp    804913d <launch+0x45>
 804918a:	89 f6                	mov    %esi,%esi

0804918c <main>:
 804918c:	55                   	push   %ebp
 804918d:	89 e5                	mov    %esp,%ebp
 804918f:	57                   	push   %edi
 8049190:	56                   	push   %esi
 8049191:	53                   	push   %ebx
 8049192:	83 ec 0c             	sub    $0xc,%esp
 8049195:	83 e4 f0             	and    $0xfffffff0,%esp
 8049198:	83 ec 08             	sub    $0x8,%esp
 804919b:	68 78 90 04 08       	push   $0x8049078
 80491a0:	6a 0b                	push   $0xb
 80491a2:	8b 75 08             	mov    0x8(%ebp),%esi
 80491a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 80491a8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 80491af:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
 80491b6:	e8 79 f5 ff ff       	call   8048734 <signal@plt>
 80491bb:	59                   	pop    %ecx
 80491bc:	5f                   	pop    %edi
 80491bd:	68 50 90 04 08       	push   $0x8049050
 80491c2:	6a 07                	push   $0x7
 80491c4:	e8 6b f5 ff ff       	call   8048734 <signal@plt>
 80491c9:	58                   	pop    %eax
 80491ca:	5a                   	pop    %edx
 80491cb:	68 a0 90 04 08       	push   $0x80490a0
 80491d0:	6a 0e                	push   $0xe
 80491d2:	e8 5d f5 ff ff       	call   8048734 <signal@plt>
 80491d7:	5f                   	pop    %edi
 80491d8:	58                   	pop    %eax
 80491d9:	68 d0 90 04 08       	push   $0x80490d0
 80491de:	6a 04                	push   $0x4
 80491e0:	e8 4f f5 ff ff       	call   8048734 <signal@plt>
 80491e5:	a1 c4 a1 04 08       	mov    0x804a1c4,%eax
 80491ea:	a3 0c a0 04 08       	mov    %eax,0x804a00c
 80491ef:	90                   	nop
 80491f0:	83 c4 10             	add    $0x10,%esp
 80491f3:	50                   	push   %eax
 80491f4:	68 bb 96 04 08       	push   $0x80496bb
 80491f9:	53                   	push   %ebx
 80491fa:	56                   	push   %esi
 80491fb:	e8 74 f5 ff ff       	call   8048774 <getopt@plt>
 8049200:	83 c4 10             	add    $0x10,%esp
 8049203:	3c ff                	cmp    $0xff,%al
 8049205:	0f 84 08 01 00 00    	je     8049313 <main+0x187>
 804920b:	0f be c0             	movsbl %al,%eax
 804920e:	83 e8 66             	sub    $0x66,%eax
 8049211:	83 f8 12             	cmp    $0x12,%eax
 8049214:	0f 87 e2 00 00 00    	ja     80492fc <main+0x170>
 804921a:	ff 24 85 48 9b 04 08 	jmp    *0x8049b48(,%eax,4)
 8049221:	8d 76 00             	lea    0x0(%esi),%esi
 8049224:	c7 05 24 a0 04 08 01 	movl   $0x1,0x804a024
 804922b:	00 00 00 
 804922e:	c7 05 14 a0 04 08 01 	movl   $0x1,0x804a014
 8049235:	00 00 00 
 8049238:	c7 05 5c a0 04 08 01 	movl   $0x1,0x804a05c
 804923f:	00 00 00 
 8049242:	eb af                	jmp    80491f3 <main+0x67>
 8049244:	83 ec 08             	sub    $0x8,%esp
 8049247:	68 54 96 04 08       	push   $0x8049654
 804924c:	ff 35 c8 a1 04 08    	pushl  0x804a1c8
 8049252:	e8 bd f5 ff ff       	call   8048814 <fopen@plt>
 8049257:	83 c4 10             	add    $0x10,%esp
 804925a:	85 c0                	test   %eax,%eax
 804925c:	a3 0c a0 04 08       	mov    %eax,0x804a00c
 8049261:	75 90                	jne    80491f3 <main+0x67>
 8049263:	83 ec 08             	sub    $0x8,%esp
 8049266:	ff 35 c8 a1 04 08    	pushl  0x804a1c8
 804926c:	68 c1 96 04 08       	push   $0x80496c1
 8049271:	e8 2e f5 ff ff       	call   80487a4 <printf@plt>
 8049276:	58                   	pop    %eax
 8049277:	90                   	nop
 8049278:	ff 33                	pushl  (%ebx)
 804927a:	e8 8d fd ff ff       	call   804900c <usage>
 804927f:	e9 6c ff ff ff       	jmp    80491f0 <main+0x64>
 8049284:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
 804928b:	c7 45 e8 05 00 00 00 	movl   $0x5,-0x18(%ebp)
 8049292:	e9 5c ff ff ff       	jmp    80491f3 <main+0x67>
 8049297:	90                   	nop
 8049298:	c7 05 14 a0 04 08 01 	movl   $0x1,0x804a014
 804929f:	00 00 00 
 80492a2:	e9 4c ff ff ff       	jmp    80491f3 <main+0x67>
 80492a7:	90                   	nop
 80492a8:	c7 05 10 a0 04 08 01 	movl   $0x1,0x804a010
 80492af:	00 00 00 
 80492b2:	e9 3c ff ff ff       	jmp    80491f3 <main+0x67>
 80492b7:	90                   	nop
 80492b8:	83 ec 0c             	sub    $0xc,%esp
 80492bb:	ff 35 c8 a1 04 08    	pushl  0x804a1c8
 80492c1:	e8 ee f4 ff ff       	call   80487b4 <__strdup@plt>
 80492c6:	5a                   	pop    %edx
 80492c7:	59                   	pop    %ecx
 80492c8:	50                   	push   %eax
 80492c9:	68 d6 96 04 08       	push   $0x80496d6
 80492ce:	a3 20 a0 04 08       	mov    %eax,0x804a020
 80492d3:	e8 cc f4 ff ff       	call   80487a4 <printf@plt>
 80492d8:	5f                   	pop    %edi
 80492d9:	ff 35 20 a0 04 08    	pushl  0x804a020
 80492df:	e8 64 01 00 00       	call   8049448 <gencookie>
 80492e4:	5a                   	pop    %edx
 80492e5:	59                   	pop    %ecx
 80492e6:	50                   	push   %eax
 80492e7:	68 e0 96 04 08       	push   $0x80496e0
 80492ec:	a3 1c a0 04 08       	mov    %eax,0x804a01c
 80492f1:	e8 ae f4 ff ff       	call   80487a4 <printf@plt>
 80492f6:	e9 f5 fe ff ff       	jmp    80491f0 <main+0x64>
 80492fb:	90                   	nop
 80492fc:	83 ec 0c             	sub    $0xc,%esp
 80492ff:	e9 74 ff ff ff       	jmp    8049278 <main+0xec>
 8049304:	c7 05 18 a0 04 08 01 	movl   $0x1,0x804a018
 804930b:	00 00 00 
 804930e:	e9 e0 fe ff ff       	jmp    80491f3 <main+0x67>
 8049313:	a1 20 a0 04 08       	mov    0x804a020,%eax
 8049318:	85 c0                	test   %eax,%eax
 804931a:	0f 84 a7 00 00 00    	je     80493c7 <main+0x23b>
 8049320:	83 ec 0c             	sub    $0xc,%esp
 8049323:	ff 35 1c a0 04 08    	pushl  0x804a01c
 8049329:	e8 f6 f4 ff ff       	call   8048824 <srandom@plt>
 804932e:	e8 21 f4 ff ff       	call   8048754 <random@plt>
 8049333:	5b                   	pop    %ebx
 8049334:	5e                   	pop    %esi
 8049335:	6a 04                	push   $0x4
 8049337:	89 45 f0             	mov    %eax,-0x10(%ebp)
 804933a:	ff 75 e8             	pushl  -0x18(%ebp)
 804933d:	81 65 f0 f8 ff 0f 00 	andl   $0xffff8,-0x10(%ebp)
 8049344:	e8 9b f4 ff ff       	call   80487e4 <calloc@plt>
 8049349:	8b 7d e8             	mov    -0x18(%ebp),%edi
 804934c:	31 db                	xor    %ebx,%ebx
 804934e:	83 ef 02             	sub    $0x2,%edi
 8049351:	83 c4 10             	add    $0x10,%esp
 8049354:	39 fb                	cmp    %edi,%ebx
 8049356:	89 c6                	mov    %eax,%esi
 8049358:	7c 5b                	jl     80493b5 <main+0x229>
 804935a:	83 7d e8 01          	cmpl   $0x1,-0x18(%ebp)
 804935e:	7e 0b                	jle    804936b <main+0x1df>
 8049360:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8049363:	c7 44 86 f8 38 00 00 	movl   $0x38,-0x8(%esi,%eax,4)
 804936a:	00 
 804936b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 804936e:	83 ec 0c             	sub    $0xc,%esp
 8049371:	c7 44 86 fc 00 00 00 	movl   $0x0,-0x4(%esi,%eax,4)
 8049378:	00 
 8049379:	ff 35 5c a0 04 08    	pushl  0x804a05c
 804937f:	31 db                	xor    %ebx,%ebx
 8049381:	e8 fe f4 ff ff       	call   8048884 <alarm@plt>
 8049386:	83 c4 10             	add    $0x10,%esp
 8049389:	3b 5d e8             	cmp    -0x18(%ebp),%ebx
 804938c:	7c 0a                	jl     8049398 <main+0x20c>
 804938e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8049391:	5b                   	pop    %ebx
 8049392:	5e                   	pop    %esi
 8049393:	31 c0                	xor    %eax,%eax
 8049395:	5f                   	pop    %edi
 8049396:	c9                   	leave  
 8049397:	c3                   	ret    
 8049398:	8b 45 f0             	mov    -0x10(%ebp),%eax
 804939b:	83 ec 08             	sub    $0x8,%esp
 804939e:	03 04 9e             	add    (%esi,%ebx,4),%eax
 80493a1:	50                   	push   %eax
 80493a2:	ff 75 ec             	pushl  -0x14(%ebp)
 80493a5:	43                   	inc    %ebx
 80493a6:	e8 4d fd ff ff       	call   80490f8 <launch>
 80493ab:	83 c4 10             	add    $0x10,%esp
 80493ae:	3b 5d e8             	cmp    -0x18(%ebp),%ebx
 80493b1:	7c e5                	jl     8049398 <main+0x20c>
 80493b3:	eb d9                	jmp    804938e <main+0x202>
 80493b5:	e8 9a f3 ff ff       	call   8048754 <random@plt>
 80493ba:	83 e0 38             	and    $0x38,%eax
 80493bd:	89 04 9e             	mov    %eax,(%esi,%ebx,4)
 80493c0:	43                   	inc    %ebx
 80493c1:	39 fb                	cmp    %edi,%ebx
 80493c3:	7c f0                	jl     80493b5 <main+0x229>
 80493c5:	eb 93                	jmp    804935a <main+0x1ce>
 80493c7:	83 ec 0c             	sub    $0xc,%esp
 80493ca:	68 20 9b 04 08       	push   $0x8049b20
 80493cf:	e8 90 f3 ff ff       	call   8048764 <puts@plt>
 80493d4:	5f                   	pop    %edi
 80493d5:	ff 33                	pushl  (%ebx)
 80493d7:	e8 30 fc ff ff       	call   804900c <usage>
 80493dc:	83 c4 10             	add    $0x10,%esp
 80493df:	e9 3c ff ff ff       	jmp    8049320 <main+0x194>

080493e4 <hash>:
 80493e4:	55                   	push   %ebp
 80493e5:	89 e5                	mov    %esp,%ebp
 80493e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
 80493ea:	53                   	push   %ebx
 80493eb:	8a 11                	mov    (%ecx),%dl
 80493ed:	31 db                	xor    %ebx,%ebx
 80493ef:	84 d2                	test   %dl,%dl
 80493f1:	74 1b                	je     804940e <hash+0x2a>
 80493f3:	90                   	nop
 80493f4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
 80493f7:	8d 04 83             	lea    (%ebx,%eax,4),%eax
 80493fa:	c1 e0 03             	shl    $0x3,%eax
 80493fd:	29 d8                	sub    %ebx,%eax
 80493ff:	0f be d2             	movsbl %dl,%edx
 8049402:	41                   	inc    %ecx
 8049403:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 8049406:	8a 01                	mov    (%ecx),%al
 8049408:	84 c0                	test   %al,%al
 804940a:	88 c2                	mov    %al,%dl
 804940c:	75 e6                	jne    80493f4 <hash+0x10>
 804940e:	89 d8                	mov    %ebx,%eax
 8049410:	5b                   	pop    %ebx
 8049411:	c9                   	leave  
 8049412:	c3                   	ret    
 8049413:	90                   	nop

08049414 <check>:
 8049414:	55                   	push   %ebp
 8049415:	89 e5                	mov    %esp,%ebp
 8049417:	53                   	push   %ebx
 8049418:	8b 5d 08             	mov    0x8(%ebp),%ebx
 804941b:	89 d8                	mov    %ebx,%eax
 804941d:	c1 e8 1c             	shr    $0x1c,%eax
 8049420:	31 d2                	xor    %edx,%edx
 8049422:	85 c0                	test   %eax,%eax
 8049424:	74 17                	je     804943d <check+0x29>
 8049426:	31 c9                	xor    %ecx,%ecx
 8049428:	89 d8                	mov    %ebx,%eax
 804942a:	d3 e8                	shr    %cl,%eax
 804942c:	3c 0a                	cmp    $0xa,%al
 804942e:	74 14                	je     8049444 <check+0x30>
 8049430:	83 c1 08             	add    $0x8,%ecx
 8049433:	83 f9 1f             	cmp    $0x1f,%ecx
 8049436:	7e f0                	jle    8049428 <check+0x14>
 8049438:	ba 01 00 00 00       	mov    $0x1,%edx
 804943d:	89 d0                	mov    %edx,%eax
 804943f:	8b 1c 24             	mov    (%esp),%ebx
 8049442:	c9                   	leave  
 8049443:	c3                   	ret    
 8049444:	31 d2                	xor    %edx,%edx
 8049446:	eb f5                	jmp    804943d <check+0x29>

08049448 <gencookie>:
 8049448:	55                   	push   %ebp
 8049449:	89 e5                	mov    %esp,%ebp
 804944b:	53                   	push   %ebx
 804944c:	83 ec 10             	sub    $0x10,%esp
 804944f:	ff 75 08             	pushl  0x8(%ebp)
 8049452:	e8 8d ff ff ff       	call   80493e4 <hash>
 8049457:	89 04 24             	mov    %eax,(%esp)
 804945a:	e8 65 f3 ff ff       	call   80487c4 <srand@plt>
 804945f:	83 c4 10             	add    $0x10,%esp
 8049462:	89 f6                	mov    %esi,%esi
 8049464:	e8 0b f4 ff ff       	call   8048874 <rand@plt>
 8049469:	83 ec 0c             	sub    $0xc,%esp
 804946c:	50                   	push   %eax
 804946d:	89 c3                	mov    %eax,%ebx
 804946f:	e8 a0 ff ff ff       	call   8049414 <check>
 8049474:	83 c4 10             	add    $0x10,%esp
 8049477:	85 c0                	test   %eax,%eax
 8049479:	74 e9                	je     8049464 <gencookie+0x1c>
 804947b:	89 d8                	mov    %ebx,%eax
 804947d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 8049480:	c9                   	leave  
 8049481:	c3                   	ret    
 8049482:	90                   	nop
 8049483:	90                   	nop

08049484 <__libc_csu_init>:
 8049484:	55                   	push   %ebp
 8049485:	89 e5                	mov    %esp,%ebp
 8049487:	56                   	push   %esi
 8049488:	53                   	push   %ebx
 8049489:	e8 3e f2 ff ff       	call   80486cc <_init>
 804948e:	b8 00 a0 04 08       	mov    $0x804a000,%eax
 8049493:	2d 00 a0 04 08       	sub    $0x804a000,%eax
 8049498:	c1 f8 02             	sar    $0x2,%eax
 804949b:	31 db                	xor    %ebx,%ebx
 804949d:	39 c3                	cmp    %eax,%ebx
 804949f:	73 0f                	jae    80494b0 <__libc_csu_init+0x2c>
 80494a1:	89 c6                	mov    %eax,%esi
 80494a3:	90                   	nop
 80494a4:	ff 14 9d 00 a0 04 08 	call   *0x804a000(,%ebx,4)
 80494ab:	43                   	inc    %ebx
 80494ac:	39 f3                	cmp    %esi,%ebx
 80494ae:	72 f4                	jb     80494a4 <__libc_csu_init+0x20>
 80494b0:	5b                   	pop    %ebx
 80494b1:	5e                   	pop    %esi
 80494b2:	c9                   	leave  
 80494b3:	c3                   	ret    

080494b4 <__libc_csu_fini>:
 80494b4:	55                   	push   %ebp
 80494b5:	89 e5                	mov    %esp,%ebp
 80494b7:	53                   	push   %ebx
 80494b8:	50                   	push   %eax
 80494b9:	b8 00 a0 04 08       	mov    $0x804a000,%eax
 80494be:	2d 00 a0 04 08       	sub    $0x804a000,%eax
 80494c3:	c1 f8 02             	sar    $0x2,%eax
 80494c6:	85 c0                	test   %eax,%eax
 80494c8:	8d 58 ff             	lea    -0x1(%eax),%ebx
 80494cb:	75 0b                	jne    80494d8 <__libc_csu_fini+0x24>
 80494cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 80494d0:	c9                   	leave  
 80494d1:	e9 36 00 00 00       	jmp    804950c <_fini>
 80494d6:	89 f6                	mov    %esi,%esi
 80494d8:	ff 14 9d 00 a0 04 08 	call   *0x804a000(,%ebx,4)
 80494df:	89 da                	mov    %ebx,%edx
 80494e1:	4b                   	dec    %ebx
 80494e2:	85 d2                	test   %edx,%edx
 80494e4:	75 f2                	jne    80494d8 <__libc_csu_fini+0x24>
 80494e6:	eb e5                	jmp    80494cd <__libc_csu_fini+0x19>

080494e8 <__do_global_ctors_aux>:
 80494e8:	55                   	push   %ebp
 80494e9:	89 e5                	mov    %esp,%ebp
 80494eb:	53                   	push   %ebx
 80494ec:	52                   	push   %edx
 80494ed:	a1 28 a1 04 08       	mov    0x804a128,%eax
 80494f2:	83 f8 ff             	cmp    $0xffffffff,%eax
 80494f5:	bb 28 a1 04 08       	mov    $0x804a128,%ebx
 80494fa:	74 0c                	je     8049508 <__do_global_ctors_aux+0x20>
 80494fc:	83 eb 04             	sub    $0x4,%ebx
 80494ff:	ff d0                	call   *%eax
 8049501:	8b 03                	mov    (%ebx),%eax
 8049503:	83 f8 ff             	cmp    $0xffffffff,%eax
 8049506:	75 f4                	jne    80494fc <__do_global_ctors_aux+0x14>
 8049508:	58                   	pop    %eax
 8049509:	5b                   	pop    %ebx
 804950a:	c9                   	leave  
 804950b:	c3                   	ret    

Disassembly of section .fini:

0804950c <_fini>:
 804950c:	55                   	push   %ebp
 804950d:	89 e5                	mov    %esp,%ebp
 804950f:	53                   	push   %ebx
 8049510:	52                   	push   %edx
 8049511:	e8 00 00 00 00       	call   8049516 <_fini+0xa>
 8049516:	5b                   	pop    %ebx
 8049517:	81 c3 26 0c 00 00    	add    $0xc26,%ebx
 804951d:	e8 da f3 ff ff       	call   80488fc <__do_global_dtors_aux>
 8049522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 8049525:	c9                   	leave  
 8049526:	c3                   	ret    
